shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float scroll_speed = .1;

void fragment() {
	vec2 moving_uv = vec2(fract(UV.x - TIME * scroll_speed), UV.y);
	vec4 in_tex = texture(TEXTURE, moving_uv);
	COLOR = in_tex;
}