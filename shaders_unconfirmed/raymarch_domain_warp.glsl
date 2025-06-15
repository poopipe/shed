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

float sd_repeat_3d(vec3 p, float spacing){
  vec3 id = round(p / spacing);
  vec3 offset_direction = sign(p - spacing * id)  ;
  float distance = MAX_DISTANCE;

  for(int k = 0; k < 2; k++){
    for(int j = 0; j < 2; j++){
      for(int i = 0; i <2; i++){
      // row i tihnk
        vec3 rid = id + vec3(i, j, k) * offset_direction;
        rid = clamp(rid, vec3(-0.0, 0.0, -16.0), vec3(16.0, 0.0, 16.0));
        vec3 r = p - spacing * rid;
        float y = 1.0 ;
       
        //distance = min(distance, sd_torus(r, vec2(0.1, 0.05)));
        //distance = min(distance, sd_cylinder_infinite(r, vec3(0.0, 0.0, 0.1)));
        distance = min(distance, sd_cylinder(r, 0.2, 0.4 ));

        /*
        //distance = min(distance, sd_sphere(r,vec3(0.0, y, 0.0), 0.3));
        distance = min(distance, sd_box(r, vec3(0.2 , y, 0.2 ), 0.0));
        distance = subtraction_standard(sd_box_exact(r + vec3(0.25, 0.0, 0.05), vec3(0.1 , 0.2, 0.1 )), distance);
        for( int i = 0; i < 4; i++){
          distance = union_standard(sd_box_exact(r + vec3(0.19, -0.25 + (-0.25 * i), 0.0), vec3(0.02 , 0.025, 0.2 )), distance);
        }
        */
      }
    }
  }
  return distance;
}

float get_scene_distance(vec3 p){
  float d = MAX_DISTANCE;
  
  //float sp = sd_sphere(p, vec3(0.0, 1.0, 0.0), 0.7);
  float sp = sd_repeat_3d(p, 1.0);
  //d = union_smooth(d, sp, 0.0);


  float ground_plane =  sd_gradient_noise(p/4.0 + vec3(in_time, 0.0, 0.0), 0.15);
  ground_plane +=  sd_gradient_noise(p.zyx/5.0 + vec3(in_time, 0.0, 0.0), 0.15);
  ground_plane += 0.0;
  float alpha = remap(length(p.xz), 0.0, MAX_DISTANCE, 0.0, 1.0);
  alpha = 1.0;
  ground_plane = mix(ground_plane, p.y, alpha);

  float tex = texture(Texture, clamp(p.xz, 0.0, 1.0)).x;
  
  ground_plane = sd_quad(p, 
                            vec3(-1.0, 0.0, -1.0),
                            vec3(-1.0, 0.0, 1.0),
                            vec3(1.0, 0.0, 1.0),
                            vec3(1.0, 0.0, -1.0)

                         ) -0.01; 

  float u = union_standard(sp, ground_plane);
  float s = subtraction_smooth(sp,ground_plane, 0.3);
  float i = intersection_smooth(sp, ground_plane, 0.3);

  return ground_plane;
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
  vec3 light_origin = vec3(1.0, 8.0, .0) + origin;
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
  out_color = vec4(v_color, 1.0) + vec4(saturate(v_uv.x - 1.0), saturate(v_uv.y - 1.0), 0.0, 0.0);
  
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
  //col = vec3(diffuse_light);
  //col = vec3(fract(in_time));
  //col *= get_normal(p);// * diffuse_light;
  
  // depth cueing
  float depth = clamp( pow(0.6, d - 1.0) , 0.0, 1.0);
  //col *= depth; 
  // TODO: chuck some noise at the fog
  vec3 fog = vec3(p.y + 0.2);
  fog = pow(vec3(0.03), fog);
  //col = vec3(mix(col, fog, 0.6));
  //col = fog;
  out_color *= vec4(col, 1.0);


}
