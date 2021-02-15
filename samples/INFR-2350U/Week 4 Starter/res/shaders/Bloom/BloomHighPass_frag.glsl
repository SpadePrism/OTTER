#version 420

layout(binding = 0) uniform sampler2D s_screenTex; //Source image
uniform float uThreshold;

out vec4 frag_color;

in vec2 inUV;

void main() 
{
	vec4 color = texture(s_screenTex, inUV);
	
	float luminance = (color.r + color.g + color.b) / 3.0;
	
	if (luminance > uThreshold) 
	{
		frag_color = color;
	}
	else
	{
		frag_color = vec4(0.0, 0.0, 0.0, 1.0);
	}
}