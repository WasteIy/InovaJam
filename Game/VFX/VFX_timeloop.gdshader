shader_type canvas_item;

uniform float screen_width;
uniform float screen_height;

uniform float circle_size = 0.2;
uniform float fallout = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float ratio = screen_width / screen_height;
	vec2 point = vec2(0.5);
	float dist = distance(point, UV.xy);
	COLOR.a = 0.0;
	if(dist > circle_size - fallout){
		float dif = circle_size - dist;
		float percentage = dif / fallout;
		COLOR.a = 1.0 - percentage;
		COLOR.rgb = vec3(1.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
