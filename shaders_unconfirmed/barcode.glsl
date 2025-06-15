
#include f_noise_functions

uniform float in_time;

vec3 gradient_ramp(float d){
  vec3 col_a = vec3(0.0, 0.0, 0.0);
  vec3 col_b = vec3(1.0, 0.8, 1.0);
  vec3 col_c = vec3(0.0, 0.8, 1.0);

  vec3 a = mix(col_a, col_b, d);
  vec3 b = mix(col_b, col_c, d); 
  return mix(a, b, d);
}

void main() {
  // On linux AMD you must use v_color, v_uv, and anything else passed in from your vertex shader that isn't a uniform
  //   you cannot assign them and simply assign something else and you you cannnot * them by 0.0 or it fails to compile
  //   
  //   it is , however , too dumb to realise that saturate(v - 1.0) gives you 0.0 when v is normalised
  //   so that's your workaround.

  // On windows AMD this bullshit does not happen 

  // white screen = 
  out_color = vec4(v_color, 1.0) + vec4(saturate(v_uv.x - 1.0), saturate(v_uv.y - 1.0), 0.0, 0.0);

  float cells = 33;
  vec2 pos = floor(v_uv * cells);

  uint row_h =  pcg_hash(uint(pos.y * 377));
  float row_offset = float(row_h) / pow(2.0, 32.0) ;
    
  //gets us the result of pcg_hash between 0 and 1

  pos = vec2(pos.x * row_offset * 99032, pos.y);
  
  float c = float(pcg_hash(uint(pos.x + row_offset + in_time)) ) / pow(2.0, 32.0);
  


  c = smoothstep(0.0, 1.0, c);
  vec3 col = gradient_ramp(c);
  col *= mod(pos.y, 2.0);

  out_color *= vec4(col, 1.0); 
  //out_color *= vec4(row_offset, row_offset, row_offset, 0.0);
  //c *= mod(pos.y,  4.0);
  //out_color *= vec4(c, c, c, 0.0);
} 
