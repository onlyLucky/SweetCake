shader_type canvas_item;

uniform vec2 skew_amount;
uniform vec2 skew_origin;

void fragment() {
    vec2 uv = UV;
    
    // 计算倾斜
    uv.x += (uv.y - skew_origin.y) * skew_amount.x;
    uv.y += (uv.x - skew_origin.x) * skew_amount.y;
    
    // 确保UV在0-1范围内
    uv = clamp(uv, 0.0, 1.0);
     
    // 应用纹理
    COLOR = texture(TEXTURE, uv);
}
