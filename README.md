# Shed
This a bit like shadertoy but you can use your own text editor, it's written (badly) in python 3.12 and it uses normal openGL

### Before you start:
Build the code into a wheel and install it. Poetry is recommended (and the only thing tested)\
or...\
Clone and install from source location (dependencies are listed in pyproject.toml)

### Usage
Shed is intended to be run as an executable module (like pip, venv etc) 
* python3 -m shed --h for help
* python3 -m shed -f _frag_path_ to run shed. If _frag_path_ does not exist you will be prompted to create it 
* Open your favourite text editor, modify the fragment shader and save the file 
* Marvel at your creation

### Keyboard:
* __S__: Save uint16 png and 32f exr next to input fragment shader
* __D__: Save full fragment shader (with includes etc) to text file next to input fragment shader 
* __Esc__: Quit

### What it does
* Runs a window that renders a fragment shader onto a quad
* Hot-loads the fragment shader on save 
* Dumps the full fragment shader to console on load - with line numbers 
* Prints (full 32-bit precision) fragcolor of pixels you click on to console
* Supports _n_ textures (I have no idea how many)
* Supports #include statements. These load from libglsl folder - a number are supplied

### What is currently broken:
* you must make use of v_uv in your fragment shader somewhere. If you don't need it for anything, you can stuff it into the out_color alpha since that has no effect.\
eg.
```
out_color = vec4(1.0, 1.0, 1.0, v_uv.x);
```
### Dependencies
* python = "^3.12"
* moderngl = "^5.12.0"
* pygame-ce = "^2.5.2"
* opencv-python = "^4.10.0.84"
