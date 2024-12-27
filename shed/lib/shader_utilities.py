from . import file_utilities
import os
from .. import LIB_GLSL_ROOT

class Shader:
    def __init__(self, context, fragment_shader_path, shader_file, use_v_color):
        self.context = context

        # global flags - unused until we have a unified shader build thing - which may never happen
        self.use_v_color = use_v_color

        self.vs_path = os.path.join(LIB_GLSL_ROOT, 'vertex_shader.glsl')

        # path to glsl preamble - basic boilerplate - if output from vertex shader changes this could break
        self.fs_preamble = os.path.join(LIB_GLSL_ROOT,'f_required.glsl')

        # path to user code
        self.fs_path = fragment_shader_path


        # includes / textures / etc 
        self.fs_lines = shader_file.lines
        self.fs_textures = shader_file.textures     # must do this before we build fragment shader
        self.fs_includes = shader_file.includes

        # assembled fragment shader
        self.fs = self._build_fragment_shader()
        self.program = self._get_program()


    def _build_fragment_shader(self) -> str:
        # pre load all the fragment shader code - any failures here will return False 

        preamble = file_utilities.load_file_as_string(self.fs_preamble)
        textures = self.fs_textures
        includes = self.fs_includes

        body = '\n'.join(self.fs_lines)

        s = ''
        # build string, return False if preamble or body fail, includes are 'non-critical'
        if preamble:
            s = f'{s}{preamble}\n'
            if includes:
                for i in includes:
                    include_path = os.path.join(LIB_GLSL_ROOT, f'{i}.glsl')
                    #file_string = file_utilities.load_file_as_string(include_path)
                    #if file_string is not None:    # No idea how but we were getting the  main fragment
                                                    # shader path including extension in this list which
                                                    # caused load_file_as_string to return None
                                                    # this appears to no longer be a problem 
                    s = f'{s}{file_utilities.load_file_as_string(include_path)}\n'
            if textures:
                for i in range(len(textures)):
                    s = f'{s}uniform sampler2D Texture{i};\n'
            if body:
                s = f'{s}\n{body}'
            else:
                return False
        else:
            return False
        return s

    def _build_vertex_shader(self) -> str:
        # TODO:
        # NOT USED  - DEFINITELY NOT HOW YOU'D DO IT EITHER
        # we need to build vertex shader differently depending on what attributes we want available
        # eg. if we don't need vertex color, we need to not declare it in the vertex shader 
        #   it looks like the best approach is going to be to write it out in chunks similarly to the fragment shader

        vs_lines = [
            '#version 330 core\n',
            'in vec3 in_vertex;\n',
        ]

        if self.use_v_color:
            vs_lines.extend([
                'in vec3 in_color;\n'
            ])
        
        vs_lines.extend([
            'in vec2 in_uv;\n',
            'uniform vec2 in_scale;\n',
        ])
        
        if self.use_v_color:
            vs_lines.extend([
                'out vec3 v_color;\n'
            ])
       
        vs_lines.extend([
            'out vec2 v_uv;\n',
            'void main(){\n'
            ])

        if self.use_v_color:
            vs_lines.append('v_color = in_color;\n')

        vs_lines.extend([
            'v_uv = in_uv;\n',
            'gl_Position = vec4(in_vertex * vec3(in_scale.x, in_scale.y, 1.0), 1.0);\n',
            '}'
        ])

        #vs_string = file_utilities.load_file_as_string(self.vs_path)
        vs_string = ''.join(vs_lines)
        return(vs_string)

    def debug_print(self, s):
        # print s with line numbers
        lines = s.splitlines()
        [print(f'{str(i+1).ljust(4)} {lines[i]}') for i in range(len(lines))]

    def _get_program(self):
        if not self.context:
            return False
        try:
            vs = file_utilities.load_file_as_string(self.vs_path)
            fs = self.fs
            
            self.debug_print(fs)

            if fs and vs:
                program = self.context.program(
                    vertex_shader = vs,
                    fragment_shader= fs
                )
            return program

        except Exception as e:
            print('Error getting shader program')
            print(e)

        return False


