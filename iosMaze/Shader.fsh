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
uniform bool u_isFogOn;
uniform int u_fogMode;
uniform float u_fogIntensity;   // max distance or density depending on mode
uniform vec3 u_flashlightPos;
uniform vec3 u_flashlightDir;
uniform bool u_minimap;
uniform bool u_overlay;

vec4 k_dayAmbientColor = vec4(0.5, 0.5, 0, 1);
vec4 k_nightAmbientColor = vec4(0.07, 0.09, 0.38, 1);
vec4 k_fogColor = vec4(0.2, 0.2, 0.2, 1);
float k_flashlightAngle = 0.98480775301;  // precomputed value cos(10deg)
vec4 k_flashlightColor = vec4(0.5,0.5,0.5,1.0);

// returns lerped color where 0 = colA and 1.0 = colB.
vec4 lerp(vec4 colA, vec4 colB, float ratio)
{
    float cRatio = clamp(ratio, 0.0, 1.0);
    return colB * cRatio + colA * (1.0-cRatio);
}

void main()
{
//    vec3 eyeNormal = normalize(normalMatrix * v_normal);
//    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
//    vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
//    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    // special overlay object
    if (u_overlay)
    {
        o_fragColor = vec4(0.0, 0.0, 0.0, 0.5);
        return;
    }
    
    vec4 finalColor = (u_isDaytime) ? k_dayAmbientColor : k_nightAmbientColor;

    // flashlight
    if (u_isFlashlightOn)
    {
        float angleToFragment = dot(normalize(v_position), vec3(0.0,0.0,-1.0));
        if (angleToFragment > k_flashlightAngle)
        {
            finalColor += k_flashlightColor;
        }
    }

    // linear fog
    if (u_fogMode == 1)
    {
        // linear fog (where intensity = max dist, 1 = closest dist)
        float fogFactor = (u_fogIntensity - length(v_position)) / (u_fogIntensity - 1.0);
        fogFactor = clamp( fogFactor, 0.0, 1.0 );

        fogFactor = 1.0 - fogFactor; // 1 = full fog, 0 = no fog

        finalColor = lerp(finalColor + texture(texSampler, v_texcoord), k_fogColor, fogFactor);
    }
    // exponential fog
    else if (u_fogMode == 2)
    {
        float fogFactor = (1.0 / exp(length(v_position) * u_fogIntensity * 0.02));
        fogFactor = 1.0 - fogFactor;
        
        finalColor = lerp(finalColor + texture(texSampler, v_texcoord), k_fogColor, fogFactor);
    }
    // no fog
    else
    {
        finalColor = finalColor + texture(texSampler, v_texcoord);
    }
    
    if (u_minimap)
    {
        finalColor.w = 0.5;
        o_fragColor = finalColor;
    }
    else
    {
        o_fragColor = finalColor;
    }    
}
