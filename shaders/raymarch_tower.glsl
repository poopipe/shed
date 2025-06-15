#include f_noise_functions
#include f_distance_functions_3d

uniform float in_time;

#define MAX_STEPS 100
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.001

float sd_gradient_noise(vec3 p, float magnitude){
  float n = gradient_noise(p.xz);
  return p.y + (n * magnitude);
}

float get_scene_distance(vec3 p){
  float d = MAX_DISTANCE;


  float ground_plane =  sd_gradient_noise(p, 0.05);
  //ground_plane +=  sd_gradient_noise(p.zyx/2.0 + vec3(in_time, 0.0, 0.0), 0.15);
  
  //float tex = texture(Texture, p.xz).x;
  float sphere = sd_sphere(p,vec3(0.0, 0.0, 0.0), 1.0);
  
  d = intersection_smooth(ground_plane, sphere, 0.01);

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

float get_light(vec3 p, vec3 origin){
  vec3 light_origin = vec3(1.0, 0.0, .0) + origin;
  vec3 l = normalize(light_origin - p);
  vec3 n = get_normal(p);

  float diffuse = clamp(dot(n, l), 0.0, 1.0);
  
  // Shadow
  float d = ray_march(p + n * SURFACE_DISTANCE * 2.0, l );
  if(d < length(light_origin - p)) diffuse *= 0.8;

  return diffuse;
}

void main() {
  // white screen = 
  
  vec2 pos = v_uv * 2.0 - 1.0;
  //pos = fract(pos);

  // set up camera 
  //vec3 ray_origin = vec3(-1.0, 2.05 , fract(in_time)  );
  vec3 ray_origin = vec3(0.0, 1.0 , -2.0  );
  vec3 target_offset = vec3(0.0, -0.5, 0.0);
  vec3 ray_direction = normalize(vec3(pos.x, -pos.y , 1.0) + target_offset);

  
  float d = ray_march(ray_origin, ray_direction) ;

  vec3 p = ray_origin + ray_direction * d;

  float diffuse_light = get_light(p, ray_origin);

  vec3 col = vec3(d/5.0);
  col = vec3(diffuse_light);
  //col = vec3(fract(in_time));
  //col *= get_normal(p);// * diffuse_light;
  
  // depth cueing
  float depth = clamp( pow(0.99, d - 3.0) , 0.0, 1.0);

  col *= depth; 
  // TODO: chuck some noise at the fog
  vec3 fog = vec3(p.y + 0.2);
  fog = pow(vec3(0.03), fog);
  //col = vec3(mix(col, fog, 0.6));
  //col = fog;
  out_color = vec4(col, 1.0);


}
