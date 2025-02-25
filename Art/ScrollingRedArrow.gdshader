shader_type canvas_item;

//uniform sampler2D image : source_color;
uniform float speed = 1;

void fragment() {
	vec2 newuv = UV;
	newuv.x -= TIME * speed;
	vec4 c = texture(TEXTURE, newuv);
	COLOR = c;
}
