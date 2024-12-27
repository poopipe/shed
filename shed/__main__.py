import os
import shutil
import argparse
from .lib import viewer

from . import LIB_GLSL_ROOT

parser = argparse.ArgumentParser()
parser.add_argument('-f', '--fragment_file', type=str, help='path to fragment shader file')
args = parser.parse_args()

fragment_path = None
if args.fragment_file:
    print(args.fragment_file)
    if not os.path.exists(args.fragment_file):
        response = input(f'{fragment_path} does not exist, create new file? Y/N: ')
        if response.lower() == 'y' or response.lower() =='yes':
            # dump a copy of the default fragment shader file into a new file 
            shutil.copyfile(os.path.join(LIB_GLSL_ROOT, 'fragment_shader.glsl'), args.fragment_file)
        else:
            print('kthxbye')
            exit(0)

    fragment_path = args.fragment_file

if fragment_path:
    viewer.main(fragment_path)
else:
    print('no fragment file supplied, I will close now')
    exit(0)


#viewer.main('/home/poopipe/src/github/shed/shed/lib_glsl/fragment_shader.glsl')
'''
if args.f:
    viewer.main(args.f)
else: 
    viewer.main()
'''
