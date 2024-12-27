
import os

def load_file_as_lines(p:str) -> list:
    try:
        if os.path.exists(p):
            with open(p) as f:
                #return [x.strip() for x in f.readlines()]
                return [x.rstrip() for x in f.readlines()]  # trying with rstrip cos it maintains indent - cant remember why i didn't initially though
        else:
            return None
    except FileNotFoundError as e:
        print(e)
        return None


def load_file_as_string(p:str) -> str:
    try:
        if os.path.exists(p):
            with open(p) as f:
                s = f.read()
            return s
        else:
            return None
    except FileNotFoundError as e:
        print(e)
        return None

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

