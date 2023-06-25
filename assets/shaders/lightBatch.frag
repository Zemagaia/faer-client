#version 400

precision lowp float;

in BatchData {
    vec2 uv;
    float color;
    float alphaMult;
} data;

layout (location = 0) out vec4 resultColor;

uniform sampler2D sampler;

void main() {
    vec4 pixel = texture(sampler, data.uv);
    if (pixel.a == 0.0)
        discard;

    int color = int(data.color);
    pixel.a *= data.alphaMult;
    if (color != -1 && pixel.a > 0.0)
        pixel.rgb = vec3(((color >> 16) & 0xFF) / 255.0, ((color >> 8) & 0xFF) / 255.0, (color & 0xFF) / 255.0);

    resultColor = pixel; 
}