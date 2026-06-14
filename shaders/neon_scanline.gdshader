shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 scan_color : source_color = vec4(0.0, 1.0, 0.4, 1.0);

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	// Horizontal scanlines pulsing
	float scanline = sin(UV.y * 180.0 + TIME * 6.0) * 0.5 + 0.5;
	vec4 glow = scan_color * scanline * intensity * 0.6;
	COLOR = base + glow;
}
