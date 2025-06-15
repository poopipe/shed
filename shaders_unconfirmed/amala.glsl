#include f_core
#include f_noise_functions
#include f_uv_functions
#include f_color_functions

#texture amala.png

uniform float in_time;
void main() {
  
  float cells = 32; 
  cells = remap(sin(in_time*0.5), -1.0, 1.0, 60, 64);
  
  vec2 pos = (v_uv *2.0 - 1.0) * cells;
  float n = gradient_noise( vec2(floor(pos.x) + in_time, 0.5)) * sin(in_time * 4.0) ;
  
  float random_v = n;// * 0.5 + 0.5 ;

  float v_offset = mod(floor(pos.x), 2.0) * 0.5 ; 
  v_offset = (v_offset * random_v)  ;
  v_offset *= 1/log2(cells);
  
  //pos = pos * 0.5 + cells/2 ;
  
  pos += vec2(0.0, v_offset * 8.0);
  
  vec4 tex = texture(Texture0, (floor(pos) * 0.5 - cells/2) / cells);

  out_color = tex;
  //out_color *= vec4(random_v, random_v, random_v, 1.0);
  out_color = vec4(pos, 0.0, 1.0);
}
 



