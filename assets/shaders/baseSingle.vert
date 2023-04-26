#version 460

precision lowp float;

layout (location = 0) in vec4 vertUV;

layout (location = 0) out vec2 uv;

layout (location = 0) uniform vec4 vertScale;
layout (location = 1) uniform vec2 vertPos;

void main() {
    gl_Position = vec4(-(vertUV.x * vertScale.x + vertUV.y * vertScale.y) + vertPos.x,
        ((vertUV.x * vertScale.z + vertUV.y * vertScale.w) + vertPos.y), 0, 1);
    uv = vertUV.zw;
}