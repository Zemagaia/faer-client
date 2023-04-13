#version 460

layout (location = 0) in vec4 vertUV;
layout (location = 1) in vec2 texelSize;
layout (location = 2) in vec2 colors;
layout (location = 3) in float flashStrength;

layout (location = 0) out vec2 uvOut;
layout (location = 1) out vec2 texelSizeOut;
layout (location = 2) out vec2 colorsOut;
layout (location = 3) out float flashStrengthOut;

void main() {
    gl_Position = vec4(vertUV.xy, 0, 1);
    uvOut = vertUV.zw;
    texelSizeOut = texelSize;
    colorsOut = colors;
    flashStrengthOut = flashStrength;
}