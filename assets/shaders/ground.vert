#version 400

precision lowp float;

layout (location = 0) in vec4 vertUV;
layout (location = 1) in vec2 leftBlendUV;
layout (location = 2) in vec2 topBlendUV;
layout (location = 3) in vec2 rightBlendUV;
layout (location = 4) in vec2 bottomBlendUV;
layout (location = 5) in vec2 baseUV;

out BatchData {
    vec2 baseUV;
    vec2 uv;
    vec2 leftBlendUV;
    vec2 topBlendUV;
    vec2 rightBlendUV;
    vec2 bottomBlendUV;
} data;

void main() {
    gl_Position = vec4(vertUV.xy, 0, 1);
    data.baseUV = vertUV.zw;
    data.uv = baseUV;
    data.leftBlendUV = leftBlendUV;
    data.topBlendUV = topBlendUV;
    data.rightBlendUV = rightBlendUV;
    data.bottomBlendUV = bottomBlendUV;
}