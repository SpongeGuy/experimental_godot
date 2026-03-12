shader_type canvas_item;

uniform float clear_radius: hint_range(0.0, 2000.0) = 100.0;
uniform vec2 center = vec2(0, 0);
uniform vec4 fog_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    COLOR = fog_color;
    vec2 screen_pos = FRAGCOORD.xy;

    if (length(screen_pos - center_pos) < clear_radius) {
        COLOR.a = 0.0;
    }
}
