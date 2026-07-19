shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float speed = 1.0;
uniform float freq = 20.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float centerDist = distance(UV, vec2(0.5));
	vec2 newUV = vec2(SCREEN_UV.x + sin(UV.y * freq + TIME * speed * freq) * 0.02 * sin(TIME), SCREEN_UV.y);
	vec4 color = texture(screen_texture, newUV);
	if(centerDist > 0.5){
		ALPHA = 0.0;
	}
	ALBEDO = color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
