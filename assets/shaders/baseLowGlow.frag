#version 400

precision lowp float;

in BatchData {
    vec2 uv;
    vec2 texelSize;
    vec2 colors;
    float flashStrength;
    float barThresh;
} data;

layout (location = 0) out vec4 resultColor;

uniform sampler2D sampler;

void main() {
    if (data.barThresh > 0 && data.barThresh < data.uv.x)
        discard;
        
    vec4 pixel = texture(sampler, data.uv);

    if (pixel.a == 0.0) {
        uint glowColor = uint(data.colors.x);
        if (data.texelSize.x != 0) {
            float alpha = texture(sampler, data.uv - data.texelSize).a;
            alpha += texture(sampler, vec2(data.uv.x - data.texelSize.x, data.uv.y + data.texelSize.y)).a;
            alpha += texture(sampler, vec2(data.uv.x + data.texelSize.x, data.uv.y - data.texelSize.y)).a;
            alpha += texture(sampler, data.uv + data.texelSize).a;

            if (alpha > 0) {
                pixel = vec4(((glowColor >> 16) & 0xFF) / 255.0,
                                ((glowColor >> 8) & 0xFF) / 255.0, 
                                (glowColor & 0xFF) / 255.0, 1.0);
            } else if (data.barThresh != -2) { // turbo hacky
                float sum = 0.0;
                for (int i = 0; i < 3; i++) {
                    float uvY = data.uv.y + data.texelSize.y * float(i - 1.5);
                    sum += texture(sampler, vec2(data.uv.x - data.texelSize.x, uvY)).a;
                    sum += texture(sampler, vec2(data.uv.x, uvY)).a;
                    sum += texture(sampler, vec2(data.uv.x + data.texelSize.x, uvY)).a;
                }
            
                if (sum == 0.0)
                    discard;
                else
                    pixel = vec4(((glowColor >> 16) & 0xFF) / 255.0,
                        ((glowColor >> 8) & 0xFF) / 255.0, 
                        (glowColor & 0xFF) / 255.0, sum / 9.0);
            }
        }
    } else {
        if (data.colors.y >= 0) {
            uint flashColor = uint(data.colors.y);
            float flashStrengthInv = 1 - data.flashStrength;
            pixel = vec4(((flashColor >> 16) & 0xFF) / 255.0 * data.flashStrength + pixel.r * flashStrengthInv,
                            ((flashColor >> 8) & 0xFF) / 255.0 * data.flashStrength + pixel.g * flashStrengthInv, 
                            (flashColor & 0xFF) / 255.0 * data.flashStrength + pixel.b * flashStrengthInv, pixel.a);
        }
    }

    resultColor = pixel;
}
