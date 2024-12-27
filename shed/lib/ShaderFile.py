from . import file_utilities



class ShaderFile:
    def __init__(self, p):
        self.lines = self._get_lines(p)                     # all lines in file at p
        self.includes, self.lines = self._get_includes()    # paths from lines starting with #include
        self.textures, self.lines = self._get_textures()    # paths from lines starting with #texture
        #self.uniforms = self._get_uniforms()               # commented these and following out as they mutate self.lines
        #self.inputs = self._get_inputs()
        #self.outputs = self._get_outputs()
        self.body = self._get_body()                        # remainder of file

    def _get_lines(self, p):
        return file_utilities.load_file_as_lines(p)

    def _get_token_lines(self, lines, token):
        tokens = None
        for i in reversed(range(len(lines))):
            if lines[i].startswith(token):
                line = lines[i]
                t = f'{line.split(token)[1].strip()}'
                if not tokens:
                    tokens = [t]
                elif not t in tokens:
                    tokens.append(t)
                lines[i] = f'//{lines[i]}'
        if tokens and len(tokens) > 0:
            tokens = list(reversed(tokens))
        return tokens, lines

    def _get_includes(self):
        return self._get_token_lines(self.lines, '#include')

    def _get_textures(self):
        return self._get_token_lines(self.lines, '#texture')

    def _get_uniforms(self):
        return self._get_token_lines(self.lines, 'uniform')
 
    def _get_inputs(self):
        return self._get_token_lines(self.lines, 'in ')

    def _get_outputs(self):
        return self._get_token_lines(self.lines, 'out ')

    def _get_body(self):
        pass


