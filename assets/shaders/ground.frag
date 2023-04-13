#version 460

layout (location = 0) in vec2 baseUV;
layout (location = 1) in vec2 uv;
layout (location = 2) in vec2 leftBlendUV;
layout (location = 3) in vec2 topBlendUV;
layout (location = 4) in vec2 rightBlendUV;
layout (location = 5) in vec2 bottomBlendUV;

layout (location = 0) out vec4 resultColor;

layout (location = 0) uniform vec2 leftMaskUV;
layout (location = 1) uniform vec2 topMaskUV;
layout (location = 2) uniform vec2 rightMaskUV;
layout (location = 3) uniform vec2 bottomMaskUV;
layout (location = 4) uniform sampler2D sampler;

void main() {
    vec4 result = texture(sampler, uv + baseUV);

    if (leftBlendUV.x >= 0 && texture(sampler, leftMaskUV + baseUV).a == 1)
        result = texture(sampler, leftBlendUV + baseUV);
    if (topBlendUV.x >= 0 && texture(sampler, topMaskUV + baseUV).a == 1)
        result = texture(sampler, topBlendUV + baseUV);
    if (rightBlendUV.x >= 0 && texture(sampler, rightMaskUV + baseUV).a == 1)
        result = texture(sampler, rightBlendUV + baseUV);
    if (bottomBlendUV.x >= 0 && texture(sampler, bottomMaskUV + baseUV).a == 1)
        result = texture(sampler, bottomBlendUV + baseUV);
    
    resultColor = result;    
}