import numpy as np

class Mesh:
    def __init__(self, context ):
        self.context = context

        self.vertex_positions = [
            # first triangle
            [ 1.0,  1.0, -1.0],
            [ 1.0, -1.0, -1.0],
            [-1.0,  1.0, -1.0],
            # second triangle
            [ 1.0, -1.0, -1.0],
            [-1.0, -1.0, -1.0],
            [-1.0,  1.0, -1.0],
        ]

        self.vertex_colors = [
            # first triangle
            [1.0, 1.0, 1.0],
            [1.0, 1.0, 1.0],
            [1.0, 1.0, 1.0],
            # second triangle
            [1.0, 1.0, 1.0],
            [1.0, 1.0, 1.0],
            [1.0, 1.0, 1.0],
        ]

        self.vertex_texcoords = [
            # first triangle
            [1.0, 0.0],
            [1.0, 1.0],
            [0.0, 0.0],
            #second triangle
            [1.0, 1.0],
            [0.0, 1.0],
            [0.0, 0.0],
        ]

        # build vertex buffer based on input
        self.vertices = self._get_vertex_array([self.vertex_positions])
        self.vbo = self.context.buffer(self.vertices.tobytes())

    def _get_vertex_array(self, data_arrays):
        arrays = zip(*data_arrays)
        unpacked = []
        for element in arrays:
            [unpacked.append(x) for x in element]
        return np.array( [x for y in unpacked for x in y], dtype=np.float32)
 
    def update_vbo(self, data_arrays):
        self.vertices = self._get_vertex_array(data_arrays)
        self.vbo = self.context.buffer(self.vertices.tobytes())



