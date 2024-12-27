#version 330 core

in vec3 in_vertex;
in vec2 in_uv;

uniform vec2  in_scale;

out vec2 v_uv;


void main() {
  v_uv = in_uv;

  gl_Position = vec4( in_vertex * vec3(in_scale.x, in_scale.y, 1.0), 1.0);
}
 
