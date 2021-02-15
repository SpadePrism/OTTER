#version 410

layout(location = 0) in vec3 inPos;
layout(location = 1) in vec3 inColor;
layout(location = 2) in vec3 inNormal;
layout(location = 3) in vec2 inUV;

// Toggle Uniforms //
uniform bool u_noneToggle;
uniform bool u_ambientToggle;
uniform bool u_specularToggle;
uniform bool u_ambspecToggle;
uniform bool u_customToggle;

uniform sampler2D s_Diffuse;
uniform sampler2D s_Diffuse2;
uniform sampler2D s_Specular;

uniform vec3  u_AmbientCol;
uniform float u_AmbientStrength;

uniform vec3  u_LightPos;
uniform vec3  u_LightCol;
uniform float u_AmbientLightStrength;
uniform float u_SpecularLightStrength;
uniform float u_Shininess;
// NEW in week 7, see https://learnopengl.com/Lighting/Light-casters for a good reference on how this all works, or
// https://developer.valvesoftware.com/wiki/Constant-Linear-Quadratic_Falloff
uniform float u_LightAttenuationConstant;
uniform float u_LightAttenuationLinear;
uniform float u_LightAttenuationQuadratic;

uniform float u_TextureMix;

uniform vec3  u_CamPos;

out vec4 frag_color;

// Toon Shading //
const int bands = 5;
const float scaleFactor = 1.0/bands;

// https://learnopengl.com/Advanced-Lighting/Advanced-Lighting
void main() {
	// Lecture 5
	vec3 ambient = u_AmbientLightStrength * u_LightCol;

	// Diffuse
	vec3 N = normalize(inNormal);
	vec3 lightDir = normalize(u_LightPos - inPos);

	float dif = max(dot(N, lightDir), 0.0);
	vec3 diffuse = dif * u_LightCol;// add diffuse intensity

	//Attenuation
	float dist = length(u_LightPos - inPos);
	float attenuation = 1.0f / (
		u_LightAttenuationConstant + 
		u_LightAttenuationLinear * dist +
		u_LightAttenuationQuadratic * dist * dist);

	// Specular
	vec3 viewDir  = normalize(u_CamPos - inPos);
	vec3 h        = normalize(lightDir + viewDir);

	// Get the specular power from the specular map
	float texSpec = texture(s_Specular, inUV).x;
	float spec = pow(max(dot(N, h), 0.0), u_Shininess); // Shininess coefficient (can be a uniform)
	vec3 specular = u_SpecularLightStrength * texSpec * spec * u_LightCol; // Can also use a specular color

	// Get the albedo from the diffuse / albedo map
	vec4 textureColor1 = texture(s_Diffuse, inUV);
	vec4 textureColor2 = texture(s_Diffuse2, inUV);
	vec4 textureColor = mix(textureColor1, textureColor2, u_TextureMix);

	// Toon Shading - Outline Effect
	float edge = (dot(viewDir, N) < 0.4) ? 0.0 : 1.0;

	vec3 result;

	// if toggles //

	// No Lighting //
	if (u_noneToggle == true)
	{
		result = inColor * textureColor.rgb;
	}
	
	// Ambient Only //
	if (u_ambientToggle == true)
	{
		result = ((u_AmbientCol * u_AmbientStrength) + (ambient * attenuation)) * inColor * textureColor.rgb;
	}
	
	// Specular Only //
	if (u_specularToggle == true)
	{
		result = ((specular) * attenuation) * inColor * textureColor.rgb;
	}
	
	// Ambient and Specular (Include Diffuse) //
	if (u_ambspecToggle == true)
	{
		result = (
			(u_AmbientCol * u_AmbientStrength) + // global ambient light
			(ambient + diffuse + specular) * attenuation // light factors from our single light
			) * inColor * textureColor.rgb; // Object color
	}
	
	// Custom - Toon Lighting //
	if (u_customToggle == true)
	{
		diffuse = floor(diffuse * bands) * scaleFactor;
	
		result = (u_AmbientCol * u_AmbientStrength) + (ambient + diffuse + specular) * edge * inColor * textureColor.rgb;
	}

	frag_color = vec4(result, textureColor.a);
}