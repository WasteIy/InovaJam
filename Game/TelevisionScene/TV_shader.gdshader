shader_type spatial;
render_mode unshaded;

uniform sampler2D main_tex : source_color, filter_linear;

uniform float scanline_count : hint_range(0, 1800) = 20.0;

vec2 uv_curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	
	uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);
	
	uv = (uv/2.0) + 0.5;
	return uv;
}

void vertex() {
	float distance_to_center = (cos(VERTEX.x/1.2) + cos(VERTEX.z/1.2))/2.0 - 0.7;
	
	VERTEX.y += distance_to_center;
}

void fragment() {
	float s = sin(uv_curve(UV).y * scanline_count * PI * 2.0 + TIME * 10.0) + 1.0;
	s = s / 2.0;
	
	if(UV.x < 0.1 || UV.x > 0.93){
		if(UV.y < 0.10 || UV.y > 0.90){
			ALPHA = 0.0;
		}
	}
	vec2 newUV = vec2(1.0 - UV.x, 1.0 - UV.y);
	
	vec3 texColor = texture(main_tex, newUV).rgb;
	ALBEDO = mix(texColor, vec3(0.01), s);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
