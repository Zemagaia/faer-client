#version 460

precision lowp float;

layout (location = 0) in vec4 vertUV;
layout (location = 1) in vec2 texelSize;
layout (location = 2) in vec2 colors;
layout (location = 3) in float flashStrength;
layout (location = 4) in float alphaMult;
layout (location = 5) in float sdfBuffer;
layout (location = 6) in float sdfSmoothing;

out BatchData {
    vec2 uv;
    vec2 texelSize;
    vec2 colors;
    float flashStrength;
    float alphaMult;
    float sdfBuffer;
    float sdfSmoothing;
} data;

void main() {
    gl_Position = vec4(vertUV.xy, 0, 1);
    data.uv = vertUV.zw;
    data.texelSize = texelSize;
    data.colors = colors;
    data.flashStrength = flashStrength;
    data.alphaMult = alphaMult;
    data.sdfBuffer = sdfBuffer;
    data.sdfSmoothing = sdfSmoothing;
}