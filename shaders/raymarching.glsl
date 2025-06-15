#include f_noise_functions

uniform float in_time;

#define MAX_STEPS 100
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.01

float union_smooth(float a, float b, float k){
  float h = clamp( 0.5 + 0.5 * (b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float sd_sphere(vec3 p, vec3 origin, float radius){
  return length(p - origin) - radius;
}

float get_scene_distance(vec3 p){

  float start_x = -4;
  float d = MAX_DISTANCE;

  for(int i = 0; i < 5; i++){
    
    float x_pos = start_x + i * 2.0;
    vec3 pos = vec3(x_pos, 2.0, 0.0);

    float x_offset = gradient_noise(pos.xx + in_time);
    float y_offset = gradient_noise(pos.xy + in_time);
    float z_offset = gradient_noise(pos.xz + in_time);
    //pos += vec3(x_offset, y_offset, z_offset);
    float sp = sd_sphere(p, pos, x_offset + 0.7);

    d = union_smooth(d, sp, 1.6);
  }


  float plane_distance = p.y; // height of ground plane 
  d = min(d, plane_distance);
  return d;
}

float ray_march(vec3 origin, vec3 direction){
  float origin_distance = 0.0; //from origin

  for(int i = 0; i < MAX_STEPS; i++){
    vec3 p = origin + origin_distance * direction;  // this is our ray -  should rename the p arg for all the functions to ray so i understand this later
    float scene_distance = get_scene_distance(p);
    origin_distance += scene_distance;
    if ( scene_distance < SURFACE_DISTANCE || origin_distance > MAX_DISTANCE) break;
  }
  return origin_distance;
}

vec3 get_normal(vec3 p){
  // i don't know how this works
  // are we sampling nearby parts of the distance field and making a vector out of them?
  float d = get_scene_distance(p);
  vec2 e = vec2(0.01, 0);

  vec3 n = d - vec3(
    get_scene_distance(p - e.xyy),
    get_scene_distance(p - e.yxy),
    get_scene_distance(p - e.yyx));

  return normalize(n);
}

float get_light(vec3 p){
  vec3 light_origin = vec3(-2.0, 5.0, -2.0);
  vec3 l = normalize(light_origin - p);
  vec3 n = get_normal(p);

  float diffuse = clamp(dot(n, l), 0.0, 1.0);
  
  // Shadow
  float d = ray_march(p + n * SURFACE_DISTANCE * 2.0, l );
  

  if(d < length(light_origin - p)) diffuse *= 0.1;

  return diffuse;
}

void main() {
  // white screen = 
  
  vec2 pos = v_uv * 2.0 - 1.0;
  pos *= 2.0;
  //pos = fract(pos);

  // set up camera 
  vec3 ray_origin = vec3(0.0, 2.0, -5.0);
  vec3 ray_target_offset = vec3(0.0, 0.25, 0.0);
  vec3 ray_direction = normalize(vec3(pos.x, -pos.y , 1.0) + ray_target_offset);

  float d = ray_march(ray_origin, ray_direction) ;
  vec3 p = ray_origin + ray_direction * d;
  float diffuse_light = get_light(p);

  //vec3 col = vec3(d/6.0);
  vec3 col = vec3(diffuse_light);
  out_color = vec4(col, 1.0);

}
