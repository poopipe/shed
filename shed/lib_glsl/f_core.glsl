const float PI = 3.14159265359;
const float twoPI = 6.2831853071;

float saturate(float v){
  return clamp(v, 0.0, 1.0);
}

float remap(float v, float min1, float max1, float min2, float max2) {
  return min2 + (v - min1) * (max2 - min2) / (max1 - min1);
}
