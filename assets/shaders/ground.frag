#version 460

precision lowp float;

in BatchData {
    vec2 baseUV;
    vec2 uv;
    vec2 leftBlendUV;
    vec2 topBlendUV;
    vec2 rightBlendUV;
    vec2 bottomBlendUV;
} data;

layout (location = 0) out vec4 resultColor;

uniform vec2 leftMaskUV;
uniform vec2 topMaskUV;
uniform vec2 rightMaskUV;
uniform vec2 bottomMaskUV;
uniform sampler2D sampler;

void main() {
    vec4 result = texture(sampler, data.uv + data.baseUV);

    if (data.leftBlendUV.x >= 0 && texture(sampler, leftMaskUV + data.baseUV).a == 1)
        result = texture(sampler, data.leftBlendUV + data.baseUV);
    if (data.topBlendUV.x >= 0 && texture(sampler, topMaskUV + data.baseUV).a == 1)
        result = texture(sampler, data.topBlendUV + data.baseUV);
    if (data.rightBlendUV.x >= 0 && texture(sampler, rightMaskUV + data.baseUV).a == 1)
        result = texture(sampler, data.rightBlendUV + data.baseUV);
    if (data.bottomBlendUV.x >= 0 && texture(sampler, bottomMaskUV + data.baseUV).a == 1)
        result = texture(sampler, data.bottomBlendUV + data.baseUV);
    
    resultColor = result;    
}