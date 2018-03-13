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
vec4 k_fogColor = vec4(0.2, 0.2, 0.2, 1);
float k_flashlightAngle = 0.98480775301;  // precomputed value cos(10deg)
bool debug_flashOn = true;
bool debug_fogOn = true;

// returns lerped color where 0 = colA and 1.0 = colB.
vec4 lerp(vec4 colA, vec4 colB, float ratio)
{
    float cRatio = clamp(ratio, 0.0, 1.0);
    return colB * cRatio + colA * (1.0-cRatio);
}

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * v_normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    vec4 ambient = (u_isDaytime) ? k_dayAmbientColor : k_nightAmbientColor;

    // flashlight
    if (debug_flashOn)
    {
        float angleToFragment = dot(normalize(v_position), vec3(0.0,0.0,-1.0));
        if (angleToFragment > k_flashlightAngle)
        {
            ambient += vec4(0.5,0.5,0.5,1.0);
        }
    }

    if (debug_fogOn)
    {
        // exponential fog (where 0.05 is fog density)
        // float fogFactor = (1.0 / exp(length(v_position) * 0.05));
        
        // linear fog (where 10 = max dist, 1 = closest dist)
        float fogFactor = (5.0 - length(v_position)) / (5.0 - 1.0);
        fogFactor = clamp( fogFactor, 0.0, 1.0 );
        
        fogFactor = 1.0 - fogFactor; // 1 = full fog, 0 = no fog
        
        o_fragColor = lerp(ambient + texture(texSampler, v_texcoord), k_fogColor, fogFactor);
    }
    else
    {
        o_fragColor = ambient + texture(texSampler, v_texcoord);
    }
    
}
