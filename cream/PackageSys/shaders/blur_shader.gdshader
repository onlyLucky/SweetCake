// optimized_gaussian_blur.gdshader
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float blur_radius : hint_range(0, 50) = 10.0;
uniform float alpha : hint_range(0, 1) = 0.8;
uniform int quality : hint_range(1, 4) = 2; // 1=最高质量, 4=最低质量

// 优化版高斯函数（避免线条问题）
float optimized_gaussian(float x, float sigma) {
    // 使用更平滑的曲线避免线条伪影
    float x_sq = x * x;
    float sigma_sq = sigma * sigma;
    
    // 添加偏移避免中心权重过高
    float offset = 0.01;
    return exp(-x_sq/(2.0 * sigma_sq + offset)) / (sqrt(2.0 * 3.14159265) * (sigma + offset));
}

// 混合函数避免线条
vec4 smooth_blend(vec4 a, vec4 b, float factor) {
    return mix(a, b, smoothstep(0.0, 1.0, factor));
}

void fragment() {
    vec2 tex_size = vec2(textureSize(screen_texture, 0));
    vec2 pixel_size = 1.0 / tex_size;
    
    // 计算sigma值（与blur_radius关联）
    float sigma = max(0.5, blur_radius * 0.3);
    
    // 动态计算采样范围
    int kernel_size = int(min(ceil(sigma * 4.0), 32.0));
    
    // === 改进的混合模糊方法（避免横竖线条） ===
    
    // 1. 对角线模糊（修复十字线条问题）
    vec4 diagonal_blur = vec4(0.0);
    float diagonal_weight = 0.0;
    
    for (int d = -kernel_size; d <= kernel_size; d += max(1, quality * 2)) {
        // 对角线方向权重更高
        float weight = optimized_gaussian(float(d), sigma * 1.2);
        vec2 offset = vec2(float(d), float(d)) * pixel_size * 0.707; // 45度角
        diagonal_blur += texture(screen_texture, SCREEN_UV + offset) * weight;
        diagonal_weight += weight;
    }
    
    // 2. 径向采样（更自然的模糊）
    vec4 radial_blur = vec4(0.0);
    float radial_weight = 0.0;
    
    const int radial_steps = 8;
    for (int angle = 0; angle < radial_steps; angle++) {
        float rad = float(angle) * (3.14159265 / float(radial_steps));
        vec2 dir = vec2(cos(rad), sin(rad));
        
        for (int r = 0; r <= kernel_size; r += quality) {
            float dist = float(r);
            float weight = optimized_gaussian(dist, sigma * 0.8);
            vec2 offset = dir * dist * pixel_size;
            radial_blur += texture(screen_texture, SCREEN_UV + offset) * weight;
            radial_weight += weight;
        }
    }
    
    // 3. 传统水平+垂直模糊（但使用改进的混合）
    vec4 horizontal_blur = vec4(0.0);
    float horizontal_weight = 0.0;
    vec4 vertical_blur = vec4(0.0);
    float vertical_weight = 0.0;
    
    for (int i = -kernel_size; i <= kernel_size; i += quality) {
        float weight = optimized_gaussian(float(i), sigma);
        
        // 水平模糊
        vec2 h_offset = vec2(float(i) * pixel_size.x, 0.0);
        horizontal_blur += texture(screen_texture, SCREEN_UV + h_offset) * weight;
        horizontal_weight += weight;
        
        // 垂直模糊
        vec2 v_offset = vec2(0.0, float(i) * pixel_size.y);
        vertical_blur += texture(screen_texture, SCREEN_UV + v_offset) * weight;
        vertical_weight += weight;
    }
    
    horizontal_blur /= horizontal_weight;
    vertical_blur /= vertical_weight;
    diagonal_blur /= diagonal_weight;
    radial_blur /= radial_weight;
    
    // === 智能混合所有模糊结果 ===
    // 避免简单平均导致的线条问题
    
    // 组合基本模糊
    vec4 base_blur = smooth_blend(horizontal_blur, vertical_blur, 0.5);
    
    // 添加对角线模糊增强
    base_blur = smooth_blend(base_blur, diagonal_blur, 0.3);
    
    // 添加径向模糊增强
    base_blur = smooth_blend(base_blur, radial_blur, 0.2);
    
    // 最终颜色
    vec4 final_color = base_blur;
    
    // === 边缘处理（避免线条） ===
    vec2 uv = SCREEN_UV;
    
    // 检查是否靠近边缘
    float edge_factor = 0.0;
    if (uv.x < pixel_size.x * 2.0 || uv.x > 1.0 - pixel_size.x * 2.0 ||
        uv.y < pixel_size.y * 2.0 || uv.y > 1.0 - pixel_size.y * 2.0) {
        edge_factor = 1.0;
    }
    
    // 边缘使用径向模糊避免线条
    if (edge_factor > 0.0) {
        final_color = mix(final_color, radial_blur, edge_factor);
    }
    
    // 应用透明度
    COLOR = final_color;
    COLOR.a *= alpha;
    
    // === 抗锯齿处理 ===
    // 添加微噪声消除线条
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    vec4 noise_color = vec4(noise * 0.01 - 0.005);
    COLOR += noise_color;
}
