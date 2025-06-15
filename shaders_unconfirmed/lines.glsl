#include f_noise_functions

uniform float in_time;
void main() {

  out_color = vec4(v_color, 1.0f);

  float cells = 16;
  vec2 pos = v_uv * cells;

  float freq = PI * 5 * cells;
  float row_offset = gradient_noise( vec2(1.22, freq * (floor(pos.y) / cells) )  ) ;
  out_color *= vec4(row_offset, row_offset, row_offset, 1.0f);

  //float col_mask = mod(floor((pos.x - in_time * 4 * row_offset * cells) / cells),2.0  );
  float col_mask = (pos.x - fract(in_time * row_offset) * cells) / cells;
  col_mask = col_mask * 2;
  out_color *= vec4(col_mask, col_mask, col_mask, 1.0);
  //out_color = vec4(0.0, floor(pos.y)/cells, 0.0, 1.0);
  }
 
