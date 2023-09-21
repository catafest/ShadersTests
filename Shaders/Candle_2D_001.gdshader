shader_type canvas_item;

void fragment ()
{
 vec2 pos = vec2(3.5, 2.5) - UV / 0.15;
 pos.x = abs(pos.x) + abs(sin(TIME)) * 0.1;
 
 if (pos.y > -6.0) { pos.y += fract(sin(TIME * 20.0) * cos(TIME)); }
 vec4 col = vec4(0.0);
 
 float y = -pow(pos.x, 3.2) / (2.0 * 0.4) * 3.3;
 float dir = length(pos - vec2(pos.x, y)) * sin(0.3);
 
 col.rg += smoothstep(1.0, 2.3, 2.0 - dir);
 col.g /= 2.4;
 col += pow(col.r, 1.1);
 
 COLOR = col;
}