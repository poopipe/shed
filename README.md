# shed
This a bit like shadertoy but you can use your own text editor and it's written (badly) in python


Usage:
Build the code into a package and install it. You can then run it using python3 -m shed -f 'path to fragment shader file.
I'll supply packages when I've worked out how to do CI/CD on github.

### What it does
* Runs a window that renders a fragment shader onto a quad
* Hot-loads the fragment shader on save 
* Dumps the full fragment shader to console on load - with line numbers 
* Prints (full 32-bit precision) fragcolor of pixels you click on to console
* Supports _n_ textures (I have no idea how many)
* Supports #include statements. These load from libglsl folder - a number are supplied

### How you do it 
1. Launch shed with the path to an existing file or with a new filename (it will create a basic fragment shader for you in this case)
2. Open your favourite text editor, modify the fragment shader and save the file 
3. Marvel at your creation


### What is currently broken:
* textures are not handled during shader reload,  this means adding/removing/changing paths does not hotload 

