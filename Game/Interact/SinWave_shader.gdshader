shader_type spatial;

uniform vec3 backgroundColor : source_color;

uniform float green_freq = 15.0;
uniform float green_amp = 0.5;
uniform float sin_emission = 7.0;

uniform float sin_size = 0.01;

uniform float red_freq = 10.0;
uniform float red_amp = 0.7;

float spike(float x) {
    float n = fract(sin(x * 12.9898) * 43758.5453);

    float base = 0.6 + n * 0.05;

    float s = step(0.9, n);

    return mix(base, 1.0, s);
}

void vertex() {
	float center_distance = (cos(VERTEX.x/1.2) + cos(VERTEX.z/1.2))/2.0 - 0.7;
	VERTEX.y += center_distance;
}

void fragment() {
	float red_ysin = sin(UV.x * red_freq) * red_amp;
	red_ysin = (red_ysin + 1.0)/2.0;
	float red_dif = abs(red_ysin - UV.y);
	if(red_dif < sin_size){
		float dif_percentage = 1.0 - red_dif / sin_size;
		float cos_percentage = cos(dif_percentage * 1.0);
		ALBEDO = vec3(cos_percentage * spike(TIME * 0.5), 0.0, 0.0);
		EMISSION = ALBEDO * sin_emission * cos_percentage;
	}
	
	float green_ySin = sin(UV.x * green_freq) * green_amp;
	green_ySin = (green_ySin + 1.0) / 2.0; //Normalize to sin between 0.0 and 1.0
	float green_difY = abs(green_ySin - UV.y);
	if(green_difY < sin_size){
		float dif_percentage = 1.0 - green_difY / sin_size;
		float cos_percentage = cos(dif_percentage * 1.0);
		ALBEDO = vec3(0.0, cos_percentage * spike(TIME * 0.5), 0.0);
		EMISSION = ALBEDO * sin_emission * cos_percentage;
	}
	
	ALBEDO = backgroundColor;
	
	float centerDistance = distance(UV, vec2(0.5));
	if(centerDistance > 0.45){
		ALPHA = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
