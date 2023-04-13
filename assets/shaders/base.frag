#version 460

layout (location = 0) in vec2 inUv;
layout (location = 1) in vec2 texelSize;
layout (location = 2) in vec2 colors;
layout (location = 3) in float flashStrength;

layout (location = 0) out vec4 resultColor;

layout (location = 0) uniform sampler2D sampler;

void main() {
    vec4 pixel = texture(sampler, inUv);

    int glowColor = int(colors.x); 
    int flashColor = int(colors.y);
    if (texelSize.x != 0 && pixel.a < 1.0) {
        float alpha = texture(sampler, inUv - texelSize).a;
        alpha += texture(sampler, vec2(inUv.x - texelSize.x, inUv.y + texelSize.y)).a;
        alpha += texture(sampler, vec2(inUv.x + texelSize.x, inUv.y - texelSize.y)).a;
        alpha += texture(sampler, inUv + texelSize).a;

        if (alpha > 0)
            pixel = vec4(((glowColor >> 16) & 0xFF) / 255.0,
                ((glowColor >> 8) & 0xFF) / 255.0, 
                (glowColor & 0xFF) / 255.0, 1.0);
    }

    if (flashColor != -1 && pixel.a > 0) {
        float flashStrengthInv = 1 - flashStrength;
        pixel = vec4(((flashColor >> 16) & 0xFF) / 255.0 * flashStrength + pixel.r * flashStrengthInv,
                        ((flashColor >> 8) & 0xFF) / 255.0 * flashStrength + pixel.g * flashStrengthInv, 
                        (flashColor & 0xFF) / 255.0 * flashStrength + pixel.b * flashStrengthInv, pixel.a);
    }
  
    resultColor = pixel;
}
