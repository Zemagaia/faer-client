#version 460

precision lowp float;

in vec2 uv;

layout (location = 0) out vec4 resultColor;

uniform vec2 texelSize;
uniform int color;
uniform float alphaMult;
uniform sampler2D sampler;

void main() {
    vec4 pixel = texture(sampler, uv);

    pixel.a *= alphaMult;
    if (color != -1 && pixel.a > 0.0)
        pixel.rgb = vec3(((color >> 16) & 0xFF) / 255.0, ((color >> 8) & 0xFF) / 255.0, (color & 0xFF) / 255.0);

    if (texelSize.x != 0 && pixel.a < 1.0) {
        float alpha = texture(sampler, uv - texelSize).a;
        alpha += texture(sampler, vec2(uv.x - texelSize.x, uv.y + texelSize.y)).a;
        alpha += texture(sampler, vec2(uv.x + texelSize.x, uv.y - texelSize.y)).a;
        alpha += texture(sampler, uv + texelSize).a;

        if (alpha > 0)
            pixel = vec4(0.0, 0.0, 0.0, 1.0);
    }
        
    resultColor = pixel;
}