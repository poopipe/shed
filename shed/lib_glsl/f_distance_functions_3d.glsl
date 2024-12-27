// utils
float ndot( in vec2 a, in vec2 b ) {
  return a.x * b.x - a.y * b.y; 
}

float dot2( in vec2 v ) { 
  return dot(v, v); 
}

float dot3( in vec3 v ) { 
  return dot(v, v); 
}

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

float sd_sphere(vec3 p, vec3 origin, float radius){
  return length(p - origin) - radius;
}

float sd_box(vec3 p, vec3 bounds, float radius){
  vec3 q = abs(p) - bounds + radius;
  return length(max(q, 0.0)) + min( max(q.x, max(q.y, q.z)), 0.0) - radius;
}

float sd_box_exact(vec3 p, vec3 bounds){
  vec3 q = abs(p) - bounds;
  return length(max(q, 0.0)) + min( max(q.x, max(q.y, q.z)), 0.0);
}

float sd_torus(vec3 p, vec2 radius){
  vec2 q = vec2(length(p.xz) - radius.x, p.y);
  return length(q) - radius.y;
}

float sd_cylinder_infinite(vec3 p, vec3 c){
  // c[ offset x, offset z , radius] 
  return length(p.xz - c.xy) - c.z;
}

float sd_cylinder(vec3 p, float height, float radius){
  vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(radius, height);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}




float sd_quad(vec3 p, vec3 a, vec3 b, vec3 c, vec3 d){
  vec3 ba = b - a;  vec3 pa = p - a;
  vec3 cb = c - b;  vec3 pb = p - b;
  vec3 dc = d - c;  vec3 pc = p - c;
  vec3 ad = a - d;  vec3 pd = p - d;
  vec3 normal = cross(ba, ad);

  return sqrt(
    (
      sign(dot(cross(ba, normal), pa)) + 
      sign(dot(cross(cb, normal), pb)) +
      sign(dot(cross(dc, normal), pc)) +
      sign(dot(cross(ad, normal), pd)) < 3.0
    )
    ?
    min( 
      min( 
        min(
            dot3(ba * clamp(dot(ba, pa) / dot3(ba), 0.0, 1.0) - pa),
            dot3(cb * clamp(dot(cb, pb) / dot3(cb), 0.0, 1.0) - b) 
        ),
        dot3(dc * clamp(dot(dc, pc) / dot3(dc), 0.0, 1.0) - pc) 
      ),
      dot3(ad * clamp(dot(ad, pd) / dot3(ad), 0.0, 1.0) - pd) 
    )
    :
    dot(normal, pa) * dot(normal, pd) / dot3(normal) 
  );
}
