/*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/pixelate

This shader is under CC0 license. Feel free to use, improve and 
change this shader according to your needs and consider sharing 
the modified result to godotshaders.com.
*/

shader_type canvas_item;
render_mode blend_mix;

uniform int pixelate_amount = 180;
uniform float darken_amount = 1.0;

void fragment()
{
	// nearby uv coords are 'blocked' up
	vec2 grid_uv = round(UV * float(pixelate_amount)) / float(pixelate_amount);
	// sample texture color using blocky UV
	vec4 uv_text = texture(TEXTURE, grid_uv);
	
    // isolate the fade out factor by checking current Alpha channel (getting affected by Rot.gd)
    float alpha_fade = COLOR.a / max(texture(TEXTURE, UV).a, 0.0001);
    uv_text.a *= alpha_fade;
	uv_text.rgb *= darken_amount;
    COLOR = uv_text;
}