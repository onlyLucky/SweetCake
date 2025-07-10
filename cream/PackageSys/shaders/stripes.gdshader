shader_type canvas_item;

uniform float angle : hint_range(0.0, 360.0) = 30.0;
uniform float width : hint_range(0.01, 1.0) = 0.2;
uniform float softness : hint_range(0.0, 0.5) = 0.1;
uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;

void fragment() {
    float rad = radians(angle);
    vec2 dir = vec2(cos(rad), sin(rad));
    float gradient = dot(UV, dir);
    
    // 平滑过渡
    float stripe = smoothstep(0.0, softness, 
        abs(mod(gradient, width * 2.0) - width) - (width / 2.0));
    
    COLOR = mix(color_a, color_b, stripe);
}
