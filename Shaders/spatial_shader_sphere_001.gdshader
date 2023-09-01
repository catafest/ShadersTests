shader_type spatial;
uniform float var_height=3.0;
void vertex() {
	VERTEX.y += sin(TIME *var_height + VERTEX.x *var_height)+ 0.01;
}
void fragment() {
	// Place fragment code here.
	ALBEDO = vec3(0.0,0.0,1.0);
}
