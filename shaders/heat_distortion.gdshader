shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.05) = 0.008;
uniform float speed : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	float t = TIME * speed;
	vec2 uv = UV;
	// Wavy vertical distortion simulating heat
	uv.x += sin(uv.y * 40.0 + t) * strength;
	uv.y += cos(uv.x * 30.0 + t * 0.7) * strength * 0.5;
	COLOR = texture(TEXTURE, uv);
}
