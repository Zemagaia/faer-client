#version 460

precision lowp float;

layout (location = 0) in vec4 vertUV;
layout (location = 1) in vec2 lbUV;
layout (location = 2) in vec2 tbUV;
layout (location = 3) in vec2 rbUV;
layout (location = 4) in vec2 bbUV;
layout (location = 5) in vec2 bUV;

layout (location = 0) out vec2 baseUV;
layout (location = 1) out vec2 uv;
layout (location = 2) out vec2 leftBlendUV;
layout (location = 3) out vec2 topBlendUV;
layout (location = 4) out vec2 rightBlendUV;
layout (location = 5) out vec2 bottomBlendUV;

void main() {
    gl_Position = vec4(vertUV.xy, 0, 1);
    baseUV = vertUV.zw;
    uv = bUV;
    leftBlendUV = lbUV;
    topBlendUV = tbUV;
    rightBlendUV = rbUV;
    bottomBlendUV = bbUV;
}