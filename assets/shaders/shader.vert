#version 450

layout(location = 0) in vec3 inPos;
layout(location = 1) in vec3 inCol;
// layout(location = 2) in vec2 inTex;

layout(location = 0) out vec3 fragColor;
// layout(location = 1) out vec2 fragTex;


layout(push_constant) uniform Constants {
	mat4 model;
} consts;

layout(binding = 0) uniform UniformBufferObject {
    mat4 view;
    mat4 proj;
} ubo;

void main() {
    gl_Position = ubo.proj * ubo.view * consts.model * vec4(inPos, 1.0);
    fragColor = inCol;
    // fragTex = inTex;
}
