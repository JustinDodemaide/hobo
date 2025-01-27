shader_type spatial;

uniform vec3 grass_color : source_color = vec3(0.76, 0.70, 0.50); // That dusty tan we discussed earlier
uniform vec3 soil_color : source_color = vec3(0.65, 0.60, 0.45);
uniform sampler2D noise_texture;  // For ground variation
uniform float wind_speed : hint_range(0.0, 2.0) = 0.5;
uniform float wind_strength : hint_range(0.0, 1.0) = 0.2;
uniform float grass_height : hint_range(0.0, 1.0) = 0.4;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Simple wind movement - stronger at higher y values (top of grass)
    if (VERTEX.y > 0.0) {
        float wind = sin(TIME * wind_speed + world_pos.x * 0.5 + world_pos.z * 0.5);
        VERTEX.x += wind * wind_strength * VERTEX.y;
        VERTEX.z += cos(TIME * wind_speed + world_pos.x * 0.5) * wind_strength * VERTEX.y;
    }
}

void fragment() {
    // Get noise value for ground variation
    vec2 noise_uv = world_pos.xz * 0.05;  // Scale UV for reasonable noise size
    float noise = texture(noise_texture, noise_uv + vec2(TIME * 0.01)).r;

    // Mix colors based on height and noise
    float height_factor = clamp(world_pos.y / grass_height, 0.0, 1.0);
    vec3 final_color = mix(soil_color, grass_color, height_factor);

    // Add subtle noise variation
    final_color += (noise - 0.5) * 0.1;

    ALBEDO = final_color;
    ROUGHNESS = 0.9;  // Dry, rough look
    METALLIC = 0.0;
}