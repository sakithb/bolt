#version 450

layout(location = 0) out vec4 outColor;

layout(location = 0) in vec3 fragColor;
// layout(location = 1) in vec2 fragTex;

// layout(binding = 1) uniform sampler2D texSampler;

void main() {
    // outColor = texture(texSampler, fragTex);
    outColor = vec4(fragColor, 1.0);
}
