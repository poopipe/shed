vec2 cartesian2polar(vec2 pos){
  float distance = length(pos);
  float angle = atan(pos.y, pos.x);
  return vec2( (angle/twoPI) + 0.5 , distance);
}
