import os

os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
os.environ["OPENCV_IO_ENABLE_OPENEXR"]="1"
os.environ['SDL_WINDOWS_DPI_AWARENESS'] = 'permonitorv2'

import sys
import numpy as np
import moderngl
import pygame
import time
import cv2

from . import file_utilities
from . import shader_utilities
from . import mesh_utilities
from . import ShaderFile
from .. import LIB_GLSL_ROOT
from .. import LIB_RESOURCE_ROOT

class ImageTexture:
    def __init__(self, path):
        self.context = moderngl.get_context()
        self.path = path
        self.texture = self._load()
        self.sampler = self.context.sampler(texture = self.texture)

    def _load(self):
        try:
            img = cv2.imread(self.path)
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB) # optional
            #img = np.flip(img, 0).copy(order='C')      # optional
            return self.context.texture(img.shape[1::-1], img.shape[2], img)
        except Exception as e:
            print(f'Failed to load texture {self.path}')
            print(e)

    def use(self, id):
        self.sampler.use(id)


class Scene:
    def __init__(self, fragment_shader_path=os.path.join(LIB_GLSL_ROOT,'fragment_shader.glsl')):
        self.context = moderngl.get_context()
        # global flags
        self.use_v_color = False    # DO NOT USE : leaving in place in case i decide to make it work properly

        # uniforms
        self.u_time = 1.0
        self.u_scale = [1.0, 1.0]
        # window
        self.window_size = pygame.display.get_window_size()
        # shader source file
        self.fragment_shader_path = os.path.abspath(fragment_shader_path)
        self.shader_file = ShaderFile.ShaderFile(self.fragment_shader_path)
        self.texture_list = self._get_texture_list(self.shader_file.textures)
        # shader program
        self.shader = shader_utilities.Shader(self.context, self.fragment_shader_path, self.shader_file, self.use_v_color)
        self.program = self.shader.program  # TODO : this needs to come from self.shader_file
        # framebuffer
        self.fbo = self.get_frame_buffer()
        # file watching
        self.shader_file_watchers = self._get_shader_file_watchers()
        # scene
        self.scene_mesh = mesh_utilities.Mesh(self.context)
        # handle textures being there or not there 
        try:
            self.vao = self._create_vertex_array()
            if self.texture_list:
                for i in range(len(self.texture_list)):
                    if f'Texture{i}' in self.program:
                        self.program[f'Texture{i}'].value = i
                        self.texture_list[i].use(i)
        except Exception as e:
            print('Fatal error in Shader Program')
            print(e)
            exit(1)

    def _get_texture_list(self, paths:list)->list:
        if paths :
            return [ImageTexture(x) for x in paths]
        else:
            return None

    def _create_vertex_array(self):
        # get attributes listed in shader program 
        program_attributes = [x for x in self.program if isinstance(self.program[x], moderngl.Attribute)]
        #print('_create_vertex_array')
        #[print('\t', x) for x in program_attributes]

        # TODO :
        #   Offering the option of enabling/disabling things like vert color:
        #   This is not straightforward - to support disable/enable vert color:
        #       build vertex shader based on flag
        #       build fragment shader based on flag
        #       select correct parts of vbo - code for this is here and works
        #       but: 
        #           program attributes are defined by both vertex and fragment shader so shader build needs to include both
        #           order of program attributes differs on my two machines (linux/AMD : windows/Nvidia)
        #       vertex and fragment shaders rather than keeping them separate as it currently stands
        # for now we simply don't support vertex color in the default vertex and fragment shaders

        mesh_data_arrays = [
            self.scene_mesh.vertex_positions,
            self.scene_mesh.vertex_texcoords
        ]
        # add vert color if flagged on 
        if self.use_v_color:
            mesh_data_arrays.append(self.scene_mesh.vertex_colors)


        self.scene_mesh.update_vbo(mesh_data_arrays)

        # on windows, building this dynamically isn't working because the order comes out wrong - as such we must explicitly set the order 
        #vao = self.context.vertex_array(self.program, self.scene_mesh.vbo, *program_attributes)
        vao = self.context.vertex_array(self.program, self.scene_mesh.vbo, 'in_vertex', 'in_uv')
        return vao

    def reload_shader_program(self):
        # TODO:
        # Handle Textures during shader load - currently doesn't work
        try:
            self.shader_file = ShaderFile.ShaderFile(self.fragment_shader_path)
            self.shader = shader_utilities.Shader(self.context, self.fragment_shader_path, self.shader_file, self.use_v_color)
            self.program = self.shader.program
            print('fragment shader loaded:')
        except Exception as e:
            print(e)
            return False
        try:
            self.vao = self._create_vertex_array()
            if self.texture_list:
                for i in range(len(self.texture_list)):
                    if f'Texture{i}' in self.program:
                        self.program[f'Texture{i}'].value = i
                        self.texture_list[i].use(i)
        except Exception as e:
            print('Fatal error in Shader Program')
            print(e)
            return False

    def get_frame_buffer(self):
        # framebuffer
        screen = self.context.texture(self.window_size, 3, dtype='f4')
        depth = self.context.depth_texture(self.window_size)
        return self.context.framebuffer(
            color_attachments = [screen],
            depth_attachment = depth
        )

    def set_uniform(self, k, v):
        # check that a uniform exists before trying to set it
        if k in self.vao.program:
            self.vao.program[k] = v

    def set_display_scale(self):
        w,h  = self.window_size
        aspect = h / w
        if h > w:
            self.u_scale = [1.0, 1.0 / aspect]
        elif h < w:
            self.u_scale = [1.0 * aspect, 1.0]
        else:
            self.u_scale = [1.0, 1.0]
        self.set_uniform('in_scale', self.u_scale)
        self.fbo = self.get_frame_buffer()
        self.context.viewport = (0, 0, w, h)

    def save_buffer(self, buffer, path='fbo.png'):
        
        # make filename from framgent shader path - we will save next to it
        out_path = os.path.splitext(self.fragment_shader_path)[0]
        png_path = f'{out_path}_fbo.png'
        exr_path = f'{out_path}_fbo.exr'

        # this is how we save a proper floating point exr with our framebuffer in it to disk
        raw = buffer.read(components=3, dtype='f4')
        buf = np.frombuffer(raw, dtype='float32')
        buf = cv2.cvtColor(buf.reshape((*self.fbo.size[1::-1], 3)), cv2.COLOR_BGR2RGB )
        # flip vertically
        buf = np.flip(buf, axis=0)

        # exr can be saved here
        full_precision_buffer = buf 
        # apply srgb transform
        full_precision_buffer = pow(full_precision_buffer, 2.2)
        cv2.imwrite(exr_path, full_precision_buffer)
        print(f'{exr_path} saved')

        # to output a 16 bit png we need to scale it
        png_buffer = np.multiply(buf, 2**16 - 1) # need the -1 otherwise it wraps back round to 0 
        png_buffer = png_buffer.astype(np.uint16)
        cv2.imwrite(png_path, png_buffer)
        print(f'{png_path} saved')

    def pick_color(self, pos):
        u_pos, v_pos = pos 
        raw = self.fbo.read(components=3, dtype='f4')  # pull data from fbo
        # read result into numpy array cos that's a way to get actual numbers that I know about
        buf = np.frombuffer(raw, dtype='float32')
        # reshape to 2d array with 3 component lists in it
        data = buf.reshape((*self.fbo.size[1::-1], 3))
        # flip the Y axis because mouse position starts at top and openGL does not
        data = np.flip(data, axis=0)
        value = data[v_pos][u_pos]
        print(f'mouse: ({u_pos}, {v_pos}) color: ({value[0]}, {value[1]}, {value[2]})')

    def _get_shader_file_watchers(self):
        if self.shader.fs_includes:
            file_list = self.shader.fs_includes
        else:
            file_list = []
        file_list.append(self.shader.fs_path)
        return[
            file_utilities.FileWatcher(x) for x in file_list
        ]

    def watched_file_changed(self):
        for f in self.shader_file_watchers:
            if f.watch() == True:
                print(f'\n{f.file_name} changed\n')
                return True
        return False

    def render(self):
        if self.program:
            try:
                self.set_uniform('in_time', self.u_time)
                self.set_uniform('in_scale', self.u_scale)
            except Exception as e:
                print('Render:')
                print(e)
            finally:
                self.context.clear()
                self.fbo.use()
                self.vao.render()
                self.context.screen.use()
                self.vao.render()




def main(frag_path):
    pygame.init()
    pygame_screen = pygame.display.set_mode((800, 800), flags=pygame.OPENGL | pygame.DOUBLEBUF | pygame.RESIZABLE, vsync=True)

    icon = pygame.image.load(os.path.join(LIB_RESOURCE_ROOT,'icon.png'))
    pygame.display.set_icon(icon)

    pygame.display.set_caption(frag_path)
    clock = pygame.time.Clock()
    start_time = time.time()


    scene = Scene(fragment_shader_path = frag_path)

    WATCH_FILE = pygame.USEREVENT+1
    pygame.time.set_timer(WATCH_FILE, 30)


    while True:
        clock.tick(60)
        mouse_pressed = False
        mouse_released = False

        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_r:
                    scene.reload_shader_program()
                if event.key == pygame.K_s:
                    scene.save_buffer(scene.fbo)
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.VIDEORESIZE:
                scene.window_size = pygame.display.get_window_size()
                scene.set_display_scale()
            if event.type == WATCH_FILE:
                if scene.watched_file_changed():
                    scene.reload_shader_program()
                    scene.shader.debug_print(scene.shader.fs)
                    pass
            if event.type == pygame.MOUSEBUTTONDOWN:
                mouse_pressed = True
            if event.type == pygame.MOUSEBUTTONUP:
                mouse_pressed = False

        if mouse_pressed:
            mouse_pos = pygame.mouse.get_pos()
            scene.pick_color(mouse_pos)

        elapsed = time.time() - start_time
        scene.u_time = elapsed
        scene.render()
        pygame.display.flip()


if __name__ == '__main__':
    main('fragment_shader.glsl')


