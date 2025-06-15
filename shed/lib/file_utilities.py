
import os

def load_file_as_lines(p:str) -> list:
    if not os.path.exists(p):
        raise FileNotFoundError(f'{p} not found')
    with open(p) as f:
        return [x.rstrip() for x in f.readlines()]  


def load_file_as_string(p:str) -> str:
    if not os.path.exists(p):
        raise FileNotFoundError(f'{p} not found')
    with open(p) as f:
        s = f.read()
        return s

class FileWatcher():
    def __init__(self, p):
        self.cached_stamp = 0
        self.file_name = p 

    def watch(self):
        if os.path.exists(self.file_name):
            stamp = os.stat(self.file_name).st_mtime
            if stamp != self.cached_stamp:
                self.cached_stamp = stamp 
                return True
        return False

