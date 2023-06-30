#version 460

precision lowp float;

layout (location = 0) in vec4 vertUV;
layout (location = 1) in vec3 color;
layout (location = 2) in float alphaMult;

out BatchData {
    vec3 color;
    float alphaMult;
    vec2 uv;
} data;

void main() {
    gl_Position = vec4(vertUV.xy, 0, 1);
    data.uv = vertUV.zw;
    data.color = color;
    data.alphaMult = alphaMult;
}