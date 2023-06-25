#version 400

precision lowp float;

layout (location = 0) in vec4 vertUV;
layout (location = 1) in float color;
layout (location = 2) in float alphaMult;

out BatchData {
    vec2 uv;
    float color;
    float alphaMult;
} data;

void main() {
    gl_Position = vec4(vertUV.xy, 0, 1);
    data.uv = vertUV.zw;
    data.color = color;
    data.alphaMult = alphaMult;
}