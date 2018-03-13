#version 300 es

precision highp float;
in vec4 v_color;
in vec3 v_normal;
in vec2 v_texcoord;
in vec3 v_position;
out vec4 o_fragColor;

uniform sampler2D texSampler;
uniform mat3 normalMatrix;
uniform bool passThrough;
uniform bool shadeInFrag;

uniform bool u_isDaytime;
uniform bool u_isFlashlightOn;
uniform vec3 u_flashlightPos;
uniform vec3 u_flashlightDir;

vec4 k_dayAmbientColor = vec4(0.7, 0.7, 0, 1);
vec4 k_nightAmbientColor = vec4(0, 0.7, 0.7, 1);
float k_flashlightAngle = 0.98480775301;  // precomputed value cos(10deg)

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * v_normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    vec4 ambient = (u_isDaytime) ? k_dayAmbientColor : k_nightAmbientColor;

    // flashlight
    float angleToFragment = dot(normalize(v_position), vec3(0.0,0.0,-1.0));
    if (angleToFragment > k_flashlightAngle)
    {
        ambient += vec4(0.5,0.5,0.5,1.0);
    }
    
    o_fragColor = ambient + texture(texSampler, v_texcoord);
}
