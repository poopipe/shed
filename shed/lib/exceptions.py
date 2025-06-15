class ShedException(Exception):
    pass

class NoTokensError(ShedException):
    pass

class ShaderBuildError(ShedException):
    pass

class GLContextError(ShedException):
    pass
