#version 420

layout(location = 0) out vec4 frag_color;

in vec2 inUV; //inUV = TexCoords

layout (binding = 0) uniform sampler2D s_screenTex; //uTex = s_screenTex

void main() // Key Difference - No Transparency
{
	vec4 source = texture(s_screenTex, inUV);

	frag_color.rgb = source.rgb;
	frag_color.a = source.a;
}