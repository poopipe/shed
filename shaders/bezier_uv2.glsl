#include f_core

void main(){

	vec2 pos = vec2(v_uv.x, v_uv.y)  ;
	
	// points and handles
	vec2 p0 = vec2(0.1, 0.5);
	vec2 p1 = vec2(0.5, 0.75);
	vec2 p2 = vec2(0.9, 0.5);
	
	// t along segments
	float u_dot0 = dot( p1-pos, p0-p1);
	float u_dot1 = dot( p0-pos, p0-p1);
	float u_dot2 = dot( p2-pos, p1-p2);
	float u_dot3 = dot( p1-pos, p1-p2);

	// calculate t
	float u0 = min(u_dot0, u_dot1) * 1.0 / (u_dot0-u_dot1);
	float u1 = min(u_dot2, u_dot3) * 1.0 / (u_dot2-u_dot3);
	float t = u0 + u1;
	t = ((1.0 - t) * 0.5) * 0.5 + 0.5;

	// build uvs for each segment
	vec2 a = p0-pos;
	vec2 b = p0-p1;
	float c = (a.x * b.y) - (a.y * b.x);
	
	vec2 d = p1-pos;
	vec2 e = p1-p2;
	float f = (d.x * e.y) - (d.y * e.x);
	
	vec2 seg0 = vec2(min(u_dot0, u_dot1),c);
	seg0 *= 1.0 / (u_dot0-u_dot1);

	vec2 seg1 = vec2(min(u_dot2, u_dot3),f);
	seg1 *= 1.0 / (u_dot2-u_dot3);



	float u_scale = 1.0;
	float v_scale = 1.0;
	// blend segment uvs
	float u_blend = mix(seg0.x, seg1.x, t) * u_scale;
	float v_blend = mix(seg0.y, seg1.y, t) * v_scale;

	vec2 uv_blend = vec2(u_blend, v_blend);
	uv_blend = fract(uv_blend);


	// grid
	float u_grid = min(abs(u_blend), abs(u_blend-1.0));
	float v_grid = min(abs(v_blend), abs(v_blend+1.0));
	float uv_grid = min(u_grid, v_grid);
	uv_grid = smoothstep(-0.005, 0.005, uv_grid);

	// point locations
	float dist = length(pos - p0);
	dist = min(dist, length(pos - p1));
	dist = min(dist, length(pos - p2));
	dist = smoothstep(0.01, 0.009, dist);



	vec3 col = vec3(uv_blend, 0.0);
	col *= vec3(uv_grid);
	vec3 len = vec3(1.0,0.0,0.0);
	out_color = vec4( mix(len,col,1.0-dist), 1.0);





}
