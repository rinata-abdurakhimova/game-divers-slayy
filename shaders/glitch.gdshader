shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;

void fragment() {
	float t = TIME + time_offset;
	vec2 uv = UV;

	// Chromatic aberration
	float shift = intensity * 0.012;
	float r = texture(TEXTURE, uv + vec2(shift, 0.0)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(shift, 0.0)).b;

	// Horizontal scan-line glitch
	float glitch_line = step(0.98, fract(uv.y * 30.0 + t * 20.0));
	uv.x += glitch_line * intensity * 0.04;

	vec4 base = texture(TEXTURE, uv);
	COLOR = vec4(r, g, b, base.a) * (1.0 - intensity * 0.3) + vec4(intensity * 0.3, 0.0, 0.0, 0.0);
}
