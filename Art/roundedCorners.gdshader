shader_type canvas_item;

uniform float offset = 10;

void fragment() {
	vec2 dxy = UV;
	dxy.x = dxy.x > 0.5 ? 1.0 - dxy.x : dxy.x;
	dxy.y = dxy.y > 0.5 ? 1.0 - dxy.y : dxy.y;
	dxy *= TEXTURE_PIXEL_SIZE;
	if (dxy.x < offset && dxy.y < offset)
	{
		dxy -= vec2(offset, offset);
		dxy /= offset;
		float d = dxy.x * dxy.x + dxy.y * dxy.y;
		if (d > 1.0)
		{
			COLOR.a = 0.0;
		}
	}
}
