shader_type canvas_item;
uniform bool gray;
const float scale = 0.0;

void fragment() {
	if (gray) {
		float r = COLOR.r + scale;
		float g = COLOR.g + scale;
		float b = COLOR.g + scale;
		float color = r * g * b;
		COLOR.rgb = vec3(color);
	}
}
