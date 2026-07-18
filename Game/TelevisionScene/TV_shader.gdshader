shader_type spatial;

uniform sampler2D main_tex : source_color, filter_linear;

void vertex() {
	float distance_to_center = (cos(VERTEX.x/1.2) + cos(VERTEX.z/1.2))/2.0 - 0.7;
	VERTEX.y += distance_to_center;
}

void fragment() {
	vec3 texColor = texture(main_tex, UV).rgb;
	ALBEDO = texColor;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
