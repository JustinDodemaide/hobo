shader_type spatial;

uniform vec4 dry_color : source_color;
uniform vec4 wet_color : source_color;
uniform float water_height = 0.0;
uniform float blend_distance = 0.5; // How far above water level the blend occurs
uniform float wetness_darkening = 0.8; // How much darker wet areas appear
uniform float wetness_roughness = 0.6; // How rough/smooth wet areas appear

varying float vertex_height;

void vertex() {
	// Store world space height for fragment shader
	vertex_height = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
	// Calculate how "wet" this fragment should be based on height
	float wetness = 1.0 - smoothstep(water_height, water_height + blend_distance, vertex_height);

	// Blend between dry and wet colors
	vec4 base_color = mix(dry_color, wet_color, wetness);

	// Darken wet areas slightly and adjust roughness
	ALBEDO = base_color.rgb * (1.0 - wetness * wetness_darkening);
	ROUGHNESS = mix(1.0, wetness_roughness, wetness);

	// Optional: Add slight specularity to wet areas
	METALLIC = wetness * 0.1;
}