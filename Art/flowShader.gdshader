shader_type canvas_item;

//uniform sampler2D noise1;
//uniform sampler2D noise2;
uniform float speed;
uniform sampler2D color_gradient;
uniform sampler2D noiseX;
uniform sampler2D noiseY;

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

void fragment() {
	float x = texture(noiseX, UV).g;
	float y = texture(noiseY, UV).g;
	float angle = speed * TIME / 6.0 - float(int(TIME / 6.0)) * TAU;
	float dx = cos(angle);
	float dy = sin(angle);
	vec2 samplePos = vec2(x, y) / 2.0 + vec2(dx, dy) / 4.0 + vec2(0.25, 0.25);
	
	
	float worleyOuter = worley(samplePos, 4.0, 4.0);
	float worleyInner = worley(samplePos, 40.0, 40.0);
	COLOR = texture(color_gradient, vec2(worleyOuter * worleyOuter * worleyInner)).rgba;
	//COLOR = vec4(vec3(), 1.0);
}

void fragmenty() {
//	float x = texture(noiseX, UV).g;
//	float y = texture(noiseY, UV).g;
//	float angle = TIME / 6.0 - float(int(TIME / 6.0)) * TAU;
//	float dx = cos(angle);
//	float dy = sin(angle);
//	vec2 samplePos = vec2(x, y) / 2.0 + vec2(dx, dy) / 4.0 + vec2(0.25, 0.25);
//	//COLOR = texture(noise, samplePos).rgba;
//	float off1 = (texture(noise1, samplePos).g - 0.5) / 20.0;
//	float off2 = (texture(noise2, samplePos).g - 0.5) / 20.0;
//	vec3 rgbOrg = texture(TEXTURE, UV + vec2(off1, off2)).rgb;
//	vec3 rgbOff = texture(TEXTURE, UV).rgb;
//	COLOR = vec4(rgbOrg.rg, rgbOff.b, 1);
}

void fragmentx() {
	vec2 UV;
	//vec2 f = SCREEN_PIXEL_SIZE;
	vec4 color;
	int count = 0;
	float offset = float(int(TIME * 10.0) % 200) / 400.0;
	bool cnt = true;
	for (int dx = -3; cnt && dx < 4; dx += 1)
	{
		for (int dy = -3; cnt && dy < 4; dy += 1)
		{
			vec2 intersect = vec2(float(dx), float(dy));
			
			for (int i = 0; cnt && i < 101; ++i)
			{
				vec3 off1 = vec3(intersect.x / 100.0, intersect.y / 100.0, offset);
				vec3 off2 = vec3(off1.y - 0.1, off1.x - 0.1, offset); // TODO: Add a second noise
				
				//float moveX = texture(noise3D, vec3(UV.x, UV.y, 0.5)).g / 10.0;
				//float moveX = texture(noise3D, vec3(UV + off1.xy, off1.z)).g / 10.0;
				//intersect.x += moveX;
				//float moveY = texture(noise3D, vec3(UV + off2.xy, off2.z)).g / 10.0;
				//intersect.y += moveY;
				//if ((moveX > 0.001 || moveX < -0.001) && (moveY > 0.001 || moveY < -0.001))
				//{
				//	//COLOR = vec4(float(i) / 100.0, 1,0,1);
				//	cnt = false;
				//}
				
				float distSquared = intersect.x * intersect.x + intersect.y * intersect.y;
				if (distSquared > 50.0)
					break;
				if (distSquared < 2.0)
				    count += 1;
			}
			//color += texture(noise, UV + off2).rgba;
		}
	}
	
	if (cnt == true)
	{
		float c = float(count) / 600.0;
		//COLOR = vec4(c, c , c, 1);
	}
	//COLOR = texture(noise, UV).rgba;
}
