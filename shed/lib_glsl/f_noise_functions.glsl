float rand2d(in vec2 pos){
  return fract(sin(dot(pos.xy, vec2(12.9898, 78.233)))*43758.5453123);
}

uint pcg_hash(uint x)
{
  // returns a very big number,  divide by 2^32 to get something in 0-1 range 
  uint state = x * 747796405u + 2891336453u;
  uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
  return (word >> 22u) ^ word;
}


float rand(in float x){
  return fract(sin(x)*100000.0);
}

vec2 _grad( ivec2 z){
  // lifted from IQ :
  // output from this is zero centered so will need re-ranging for preview
  // 2d to 1d  - whut is the multiply for????
  int n = z.x+z.y * 11111; 

  // Hugo Elias hash - can be replaced by another one
  n = (n<<13)^n;  // this is a bitshift
  n = (n * (n*n*15731+789221)+1376312589)>>16;
#if 0
  //simple random vectors 
  return vec2(cos(float(n)), sin(float(n)));
#else
  // perlin style vectors 
  n &= 7; // bitwise AND
  vec2 gr = vec2(n&1, n>>1)*2.0 - 1.0;
  return  (n>=6) ? vec2(0.0, gr.x) :
          (n>=4) ? vec2(gr.x, 0.0) :
          gr;
#endif
}

vec2 grad(vec2 x){
  // alternative to _grad() theoretically less prone to regualarity but i dont see it
  x = fract(x * 0.3183099 + 0.1) * 17.0;
  float a = fract(x.x * x.y * (x.x + x.y));   //[0...1]
  a *= 2.0 * 3.14159287;  //[0...2PI]
  return vec2(sin(a), cos(a));
}

float gradient_noise(in vec2 p){
  ivec2 i = ivec2(floor(p));
   vec2 f =       fract(p);

  vec2 u = f*f*(3.0-2.0*f); //can replace with a quintic smoothstep 

  return mix( mix( dot( grad( i+ivec2(0,0) ),f-vec2(0.0, 0.0) ),
                   dot( grad( i+ivec2(1,0) ),f-vec2(1.0, 0.0) ), u.x),
              mix( dot( grad( i+ivec2(0,1) ),f-vec2(0.0, 1.0) ),
                   dot( grad( i+ivec2(1,1) ),f-vec2(1.0, 1.0) ), u.x), u.y);
}

float value_noise( in vec2 pos){
  vec2 i = floor(pos);
  vec2 f = fract(pos);

  // corners of 2 tile
  float a = rand2d(i);
  float b = rand2d(i + vec2(1.0, 0.0));
  float c = rand2d(i + vec2(0.0, 1.0));
  float d = rand2d(i + vec2(1.0, 1.0));

  // smooth interpolation
  vec2 u = smoothstep(0.0, 1.0 , f );

  //mix the 4 corners percentages...not gonna pretend i know what's happening here.
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
