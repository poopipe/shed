from shed.lib.exceptions import ShedException, NoTokensError
from shed.lib.file_utilities import load_file_as_lines



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
        return load_file_as_lines(p)

    def _get_token_lines(self, lines:list[str], token:str) -> tuple[list[str], list[str]]:
        tokens = []
        for i in reversed(range(len(lines))):
            if lines[i].startswith(token):
                line = lines[i]
                t = line.split(token)
                t = f'{line.split(token)[1].strip()}'
                tokens.append(t)
                lines[i] = f'//{lines[i]}'
        
        if len(tokens) <= 0:
            return [], lines 
        tokens = list(reversed(tokens))
        return tokens, lines

    def _get_includes(self):
        return self._get_token_lines(self.lines, '#include')

    def _get_textures(self)->tuple[list[str],list[str]]:
        return self._get_token_lines(self.lines, '#texture')

    def _get_uniforms(self):
        return self._get_token_lines(self.lines, 'uniform')
 
    def _get_inputs(self):
        return self._get_token_lines(self.lines, 'in ')

    def _get_outputs(self):
        return self._get_token_lines(self.lines, 'out ')

    def _get_body(self):
        return self.lines


