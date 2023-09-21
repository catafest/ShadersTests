shader_type spatial; 
//#include "res://$lib/funcs/utils.gdshaderinc"
//#include "res://$lib/funcs/colour.gdshaderinc"
//#include "res://$lib/funcs/normals.gdshaderinc"
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture,repeat_disable; 
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,repeat_disable; 
uniform vec3 surface_color:source_color;
uniform vec3 depth_color:source_color;
uniform float opacity:hint_range(0.0, 1.0)=0.5; 
uniform sampler2D _foam:source_color; 
uniform sampler2D normal_map:source_color; 
uniform float normal_scale:hint_range(-16.0, 16.0)=1.0;
uniform float beer_factor:hint_range(0.0, 10.0)=0.1; 
uniform float _roughness:hint_range(0.0, 1.0); 
uniform float _refraction:hint_range(0.00, 0.20); 
uniform float _uv_scale:hint_range(0.0, 3.0)=1.0; 
uniform float _foam_strength: hint_range(0.0, 1.0); 
uniform float _foam_size: hint_range(0.0, 0.2); 


vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}
vec3 multiply(vec3 base, vec3 blend){
	return base * blend;
}
vec3 overlay(vec3 base, vec3 blend){
	vec3 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}
vec3 soft_light(vec3 base, vec3 blend){
	vec3 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}
vec3 darken(vec3 base, vec3 blend){
	return min(base, blend);
}
vec3 color_dodge(vec3 base, vec3 blend){
	return base / (1.0 - blend);
}
vec3 linear_burn (vec3 base, vec3 blend)
{
	return base + blend - 1.0;
}

vec3 heightToNormal(float height,float strength,vec3 vertex,vec3 normal){
    vec3 worldDerivativeX = dFdx(vertex);
    vec3 worldDerivativeY = dFdy(vertex);
	
    vec3 crossX = cross(normal, worldDerivativeX);
    vec3 crossY = cross( worldDerivativeY,normal);	
    float d = dot(worldDerivativeX,crossY);
    float sgn = d < 0.0 ? (-1.0) : 1.0;
    float surface = sgn / max(0.00000000000001192093, abs(d));

    float dHdx = dFdx(height);
    float dHdy = dFdy(height);
    vec3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
    return normalize(normal - (strength * surfGrad));
}

vec3 flattenNormal(vec3 normal, float s){
	return normalize(mix(normal, vec3(0,0,1),s)); 
}
vec3 normal_strength(vec3 n, float strength)
{
    return vec3(n.rg * strength, mix(1, n.b, clamp(strength,0.0,1.0)));
}
vec3 normal_blend(vec3 A, vec3 B)
{
    return normalize(vec3(A.rg + B.rg, A.b * B.b));
}
vec3 normal_blend2(vec3 A, vec3 B)
{
    vec3 t = A.xyz + vec3(0.0, 0.0, 1.0);
    vec3 u = B.xyz * vec3(-1.0, -1.0, 1.0);
	return (t / t.z) * dot(t, u) - u;
}

float depth_proximity(float dist, vec3 vertex, sampler2D depthtex, vec2 screenuv,mat4 invproj){
	float depth_tex = textureLod(depthtex, screenuv, 0.0).r;
	vec4 depth_world_pos = invproj * vec4(screenuv * 2.0 - 1.0, depth_tex, 1.0);
	depth_world_pos.xyz /= depth_world_pos.w;
	return clamp(1.0 - smoothstep(depth_world_pos.z + dist, depth_world_pos.z, vertex.z), 0.0, 1.0);
}
float depth_linear(sampler2D depthtex, vec2 screenuv,mat4 invproj){
	float depth_tex = textureLod(depthtex,screenuv,0.0).r;
  	vec3 ndc = vec3(screenuv * 2.0 - 1.0, depth_tex);
	vec4 depth_world_pos = invproj * vec4(ndc, 1.0);	
	depth_world_pos.xyz /= depth_world_pos.w;	
	return depth_world_pos.z; 
}
float depth_proximity_z(float dist, float z,vec3 vertex){
	return clamp(1.0 - smoothstep(z + dist, z, vertex.z), 0.0, 1.0);
}

float fresnel(float power,vec3 normal,vec3 view){
	return pow(1.0 - clamp(dot(normal,view), 0.0, 1.0), power);
}

void fragment() {
	vec3 vw = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz; 
	 
	vec2 uv_scale = vw.xz * _uv_scale; 
 	vec3 n = texture(normal_map,uv_scale+TIME * 0.04).rgb;
	vec3 n2 = texture(normal_map,uv_scale-TIME * 0.06).rgb;
	vec3 n3 = texture(normal_map,uv_scale*0.3 +vec2(TIME * 0.02,TIME * -0.04)).rgb; 
	float _depth_linear = depth_linear(DEPTH_TEXTURE,SCREEN_UV,INV_PROJECTION_MATRIX);
	float d = depth_proximity_z(3.0,_depth_linear,VERTEX);
	float d2 = depth_proximity_z(0.2,_depth_linear,VERTEX); 
	
	
	d2 = 1.0-pow(d2,0.07); 
	d = exp(-d * beer_factor); 
	d +=fresnel(4.0,NORMAL,VIEW); 
	ROUGHNESS = _roughness; 	
	ALPHA = clamp(opacity+1.0-d-d2,0.0,1.0);
	vec3 n_out = normal_blend2(n3,normal_blend(n,n2)); 
	NORMAL_MAP = n_out;  
	NORMAL_MAP_DEPTH = normal_scale; 
	vec2 n_distortion = (mat3(TANGENT,BINORMAL,NORMAL) * n_out).rg * 2.0 - 1.0; 
	vec3 color_out = mix(depth_color, surface_color,d);
	vec3 _screen = texture(SCREEN_TEXTURE,SCREEN_UV+n_distortion*_refraction).rgb; 
	float depthfoam = depth_proximity_z(abs(n_distortion.r+n_distortion.g) * _foam_size ,_depth_linear,VERTEX); 
	depthfoam = pow(depthfoam,_foam_strength); 
	vec3 foam = texture(_foam,uv_scale + n_distortion).rgb; 
	ALBEDO = mix(foam,soft_light(_screen,color_out),depthfoam);  
	
}