#include f_core

vec2 get_segment_uv(vec2 p0, vec2 p1, vec2 pos){

	// u coord
	float u0 = dot( (pos-p0), normalize(p1-p0) );
	u0 /=  length(p1-p0);
	// v coord
	vec2 offset1 = p0 - pos;
	vec2 offset2 = p0 - p1;
	float v0 = offset1.x * offset2.y - offset1.y * offset2.x;

	return vec2(u0, v0); 

}

void main() {

	vec2 pos = vec2(v_uv.x, 1.0 - v_uv.y) * 6.0 - 2.0 ;
	vec2 cells = vec2(8.0);

	vec2 cell_ids = floor(pos * cells);

	vec2 cell_ids_normalised = cell_ids / cells;


	// points and handles
	vec2 p0 = vec2(0.0, 0.0);
	vec2 p1 = vec2(1.0, 0.6);
	vec2 p2 = vec2(2.0, 0.0);
	vec2 p3 = vec2(3.0, 0.1);
	
	vec2 a = get_segment_uv(p0, p1, pos);
	vec2 b = get_segment_uv(p1, p2, pos);
	vec2 c = get_segment_uv(p2, p3, pos);

	// at this point i have a normalised gradient beween each
	// point pair for u
	// these need lerping to create the curve
	// t isnt just pos.x
	//	is it the distance from pos.x to the first point? 
	//	no - 
	//	 
	float td = saturate(1.0 - a.x);
	td = td - step(1.0, td);
	vec2 d = mix(a, b, td);
	float te = b.x;
	vec2 e = mix(b, c, te);

	vec2 f = mix(d, e, saturate(1.0-c.x));

	// this is sort of working - but the accumulation 
	// of weights used for the mix is causing problems

	float dist = length(pos - p0);
	dist = min(dist, length(pos - p1));
	dist = min(dist, length(pos - p2));
	dist = min(dist, length(pos - p3));
	dist = smoothstep(0.02, 0.019, dist);
	
	// result
	vec2 r = fract(b);
	vec3 col = vec3(te, 0.0, 0.0);
	vec3 len = vec3(length(p2-p1));
	out_color = vec4( mix(len,col,1.0-dist), 1.0);
	//out_color = vec4(c.x, c.y,0.0,1.0);
}
 



