#version 300 es

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;
layout(location = 2) in vec3 normal;
layout(location = 3) in vec2 texCoordIn;
out vec4 v_color;
out vec3 v_normal;
out vec2 v_texcoord;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform bool passThrough;
uniform bool shadeInFrag;

void main()
{
    if (passThrough)
    {
        // Simple passthrough shader
        v_color = color;
        v_normal = vec3(0, 0, 0);
        v_texcoord = vec2(0, 0);
    } else if (shadeInFrag) {
        v_normal = normal;
        v_texcoord = texCoordIn;
    } else {
        // Diffuse shading
        vec3 eyeNormal = normalize(normalMatrix * normal);
        vec3 lightPosition = vec3(0.0, 0.0, 1.0);
        vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
        
        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
        
        v_color = diffuseColor * nDotVP;
        v_normal = vec3(0, 0, 0);
        v_texcoord = vec2(0, 0);
    }
    
    gl_Position = modelViewProjectionMatrix * position;
}

/* OPENGL ES 2.0 */
//attribute vec4 position;
//attribute vec4 color;
//attribute vec3 normal;
//varying vec4 v_color;
//varying vec3 v_normal;
//
//uniform mat4 modelViewProjectionMatrix;
//uniform mat3 normalMatrix;
//uniform bool passThrough;
//uniform bool shadeInFrag;
//
//void main()
//{
//    if (passThrough)
//    {
//        // Simple passthrough shader
//        v_color = color;
//        v_normal = vec3(0, 0, 0);
//    } else if (shadeInFrag) {
//        v_normal = normal;
//    } else {
//        // Diffuse shading
//        vec3 eyeNormal = normalize(normalMatrix * normal);
//        vec3 lightPosition = vec3(0.0, 0.0, 1.0);
//        vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
//
//        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
//
//        v_color = diffuseColor * nDotVP;
//    }
//
//    gl_Position = modelViewProjectionMatrix * position;
//}

