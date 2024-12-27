// compositing
float union_smooth(float a, float b, float k){
  float h = clamp( 0.5 + 0.5 * (b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float subtraction_smooth(float a, float b, float k){
  float h = clamp(0.5 - 0.5 * (b + a) / k, 0.0, 1.0);
  return mix(b, -a, h) + k * h *(1.0 - h);
}

float intersection_smooth(float a, float b, float k){
  float h = clamp(0.5 - 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) + k * h * (1.0 - h);
}

float union_standard(float a, float b){
  return min(a, b);
}

float subtraction_standard(float a, float b){
  return max(-a, b);
}

// shapes
float sd_circle(vec2 pos, vec2 center, float radius){
  return length(pos - center) - radius;
}

float sd_rounded_box(vec2 pos, vec2 center, vec2 size, vec4 radius){
  // b = size
  // r = corner roundness bottom right, top right, bottom left, top left
  pos -= center;
  radius.xy = (pos.x > 0.0) ? radius.xy : radius.zw;
  radius.x = (pos.y > 0.0) ? radius.x : radius.y;
  vec2 q = abs(pos) - size + radius.x;

  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius.x;
}

float sd_box(vec2 pos, vec2 center, vec2 size){
  pos -= center;
  vec2 d = abs(pos) - size;
  return length(max(d, 0.0)) + min( max(d.x, d.y), 0.0);
}

vec3 sdg_circle(vec2 pos, vec2 center, float radius){
  // circle with direction
  pos -= center;
  float d = length(pos);
  return vec3( d - radius, pos / d);
}

// visualisation
vec3 sd_visualise(float sd){
  vec3 col = (sd > 0.0) ? vec3(0.9, 0.4, 0.6) : vec3(0.2, 0.7, 0.85);
  col *= 1.0 - exp( -16.0 * abs(sd) );
  col *= 0.8 + 0.2 * cos(450.0 * sd);
  return col;
}
