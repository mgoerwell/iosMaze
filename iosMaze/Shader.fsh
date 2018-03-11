#version 300 es

precision highp float;
in vec4 v_color;
in vec3 v_normal;
in vec2 v_texcoord;
out vec4 o_fragColor;

uniform sampler2D texSampler;
uniform mat3 normalMatrix;
uniform bool passThrough;
uniform bool shadeInFrag;

uniform bool u_isDaytime;
uniform bool u_isFlashlightOn;

vec4 k_dayAmbientColor = vec4(0.7, 0.7, 0, 1);
vec4 k_nightAmbientColor = vec4(0, 0.7, 0.7, 1);

void main()
{
    if (!passThrough && shadeInFrag) {
        
        vec3 eyeNormal = normalize(normalMatrix * v_normal);
        vec3 lightPosition = vec3(0.0, 0.0, 1.0);
        vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
        
        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
        
        vec4 ambient = (u_isDaytime) ? k_dayAmbientColor : k_nightAmbientColor;
        
        // diffuseColor * nDotVP *
        o_fragColor = ambient * texture(texSampler, v_texcoord);
    
    } else {
        o_fragColor = v_color;
    }
}



/* OPENGL ES 2.0 */
//precision highp float;
//varying vec4 v_color;
//varying vec3 v_normal;
//
//uniform mat3 normalMatrix;
//uniform bool passThrough;
//uniform bool shadeInFrag;
//
//void main()
//{
//    if (!passThrough && shadeInFrag) {
//        vec3 eyeNormal = normalize(normalMatrix * v_normal);
//        vec3 lightPosition = vec3(0.0, 0.0, 1.0);
//        vec4 diffuseColor = vec4(0.0, 1.0, 0.0, 1.0);
//
//        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
//
////         gl_FragColor = diffuseColor * nDotVP;
//        gl_FragColor = vec4(1,0,0,1);
//    } else {
//        // gl_FragColor = v_color;
//        gl_FragColor = vec4(1,0,0,1);
//    }
//}


