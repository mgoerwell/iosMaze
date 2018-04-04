//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "Renderer.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "GLESRenderer.hpp"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_PROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASSTHROUGH,
    UNIFORM_SHADEINFRAG,
    UNIFORM_TEXTURE,
    UNIFORM_IS_DAYTIME,
    UNIFORM_IS_FLASHLIGHT_ON,
    UNIFORM_IS_FOG_ON,
    UNIFORM_FOG_MODE,
    UNIFORM_FOG_INTENSITY,
    UNIFORM_FLASHLIGHT_DIR,
    UNIFORM_FLASHLIGHT_POS,
    UNIFORM_IS_MINIMAP,
    UNIFORM_IS_OVERLAY,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface Renderer ()
{
    GLKView *theView;
    GLESRenderer glesRenderer;
    GLuint programObject;
    GLuint crateTexture;
    GLuint floorTexture;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;

    GLKMatrix4 mvp;
    GLKMatrix3 normalMatrix;
    GLKMatrix4 m;
    GLKMatrix4 v;
    GLKMatrix4 p;
    GLKMatrix4 vMap;
    GLKMatrix4 pMap;
    GLKVector3 forward;

    GLuint vertArr; // VAO that 'contains' the VBO's
    GLuint vbo;     // VBO that contains pos, color, normal, uv.
    GLuint idxBuf;  // VBO that contains index data
    
    float rotAngle;
    float rotSpeed;

    float *vertices, *normals, *texCoords;
    int *indices, numIndices;
    
    // debug variables

}
@end


@implementation Renderer

// STATIC VARIABLES
static bool isDaytime;
static bool isFlashlightOn;
static bool isFogOn;
static int fogMode;
static float fogIntensity;
static GLKVector3 camPos;
static float camXRotation;
static float camYRotation;

// STATIC GETTERS/SETTERS
+(void)setIsDaytime :(bool)isOn { isDaytime = isOn; }
+(bool)getIsDaytime { return isDaytime; }

+(void)setIsFlashlightOn :(bool)isOn { isFlashlightOn = isOn; }
+(bool)getIsFlashlightOn { return isFlashlightOn; }

+(void)setIsFogOn :(bool)isOn { isFogOn = isOn; }
+(bool)getIsFogOn { return isFogOn; }

+(void)setFogIntensity :(float)value { fogIntensity = value; }
+(void)toggleFogMode { fogMode = (fogMode >= 3) ? 0 : fogMode + 1; }

+(void)setCameraXRotation:(int)camXRot{camXRotation = camXRot;}
+(void)setCameraYRotation:(int)camYRot{camYRotation = camYRot;}
+(void)setCameraPosition:(GLKVector3)cameraPos{camPos = cameraPos;}
+(GLKVector3)getCameraPosition{return camPos;}
+(float)getCameraYRotation{return camYRotation;}

// FUNCTIONS: VIEW
- (void)dealloc
{
    glDeleteProgram(programObject);
}

// FUNCTIONS: INITIALIZATION
// Use this after [init] to instantiate to default values
- (void)setup:(GLKView *)view
{
    // Setup context
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!view.context) {
        NSLog(@"Failed to create ES context");
        view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    // Setup OpenGL settings
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    theView = view;
    [EAGLContext setCurrentContext:view.context];
    if (![self setupShaders])
    {
        NSLog(@"Failed to setup shaders");
        return;
    }
    
    self.fov = 60.0f;
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
    glEnable(GL_DEPTH_TEST);
    lastTime = std::chrono::steady_clock::now();
}

// Called by [self setup] to compile shader and retrieve uniform locations
- (bool)setupShaders
{
    // Load shaders
    char *vShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.vsh"] pathExtension]] cStringUsingEncoding:1]);
    char *fShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.fsh"] pathExtension]] cStringUsingEncoding:1]);
    programObject = glesRenderer.LoadProgram(vShaderStr, fShaderStr);
    if (programObject == 0)
    return false;
    
    // Set up uniform variables
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(programObject, "modelViewMatrix");
    uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(programObject, "projectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");
    uniforms[UNIFORM_IS_DAYTIME] = glGetUniformLocation(programObject, "u_isDaytime");
    uniforms[UNIFORM_IS_FLASHLIGHT_ON] = glGetUniformLocation(programObject, "u_isFlashlightOn");
    uniforms[UNIFORM_IS_FOG_ON] = glGetUniformLocation(programObject, "u_isFogOn");
    uniforms[UNIFORM_FOG_MODE] = glGetUniformLocation(programObject, "u_fogMode");
    uniforms[UNIFORM_FOG_INTENSITY] = glGetUniformLocation(programObject, "u_fogIntensity");
    uniforms[UNIFORM_FLASHLIGHT_DIR] = glGetUniformLocation(programObject, "u_flashlightDir");
    uniforms[UNIFORM_FLASHLIGHT_POS] = glGetUniformLocation(programObject, "u_flashlightPos");
    uniforms[UNIFORM_IS_MINIMAP] = glGetUniformLocation(programObject, "u_minimap");
    uniforms[UNIFORM_IS_OVERLAY] = glGetUniformLocation(programObject, "u_overlay");
    
    return true;
}


// FUNCTIONS: GLKIT UPDATING & DRAWING
// Update object
- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto deltaTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();
    lastTime = currentTime;
    
    // FPS view
    v = GLKMatrix4Identity;
    v = GLKMatrix4Rotate(v, GLKMathDegreesToRadians(camXRotation), 1.0, 0.0, 0.0 );
    v = GLKMatrix4Rotate(v, GLKMathDegreesToRadians(camYRotation), 0.0, 1.0, 0.0 );
    v = GLKMatrix4Translate(v, -camPos.x, -camPos.y, -camPos.z);
    forward = GLKVector3Make(v.m20, v.m21, v.m22); // cam forward
    
    float aspect = (float)theView.drawableWidth / (float)theView.drawableHeight;
    p = GLKMatrix4MakePerspective(self.fov * M_PI / 180.0f, aspect, 1.0f, 20.0f);

    // Minimap view
    vMap = GLKMatrix4MakeLookAt(
                                camPos.x, camPos.y + 10.0, camPos.z,
                                camPos.x, camPos.y, camPos.z,
                                forward.x, -forward.y, -forward.z);
    
    pMap = GLKMatrix4MakeOrtho(-3, 3, -3, 3, 0, 100);
}

- (void)drawGameObject:(GameObject *)gameObject
{
    glUseProgram ( programObject );
    
#define BUFFER_OFFSET(i) ((char *)NULL + (i))
    
    GLKMatrix4 mv = GLKMatrix4Multiply(v, [gameObject.transform GetModelMatrix]);//[gameObject.transform GetModelMatrix]);
    // 2.Load uniforms
    // uniforms
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)mv.m);
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float *)p.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);
    glUniform1i(uniforms[UNIFORM_IS_DAYTIME], isDaytime);
    glUniform1i(uniforms[UNIFORM_IS_FLASHLIGHT_ON], isFlashlightOn);
    glUniform1i(uniforms[UNIFORM_IS_FOG_ON], isFogOn);
    glUniform1i(uniforms[UNIFORM_FOG_MODE], fogMode);
    glUniform1f(uniforms[UNIFORM_FOG_INTENSITY], fogIntensity);
    
    // textures
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, gameObject.material.texture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // 3. Bind VAO
    glBindVertexArray(gameObject.model.VAO);
    
    // 4. Draw
    glDrawElements ( GL_TRIANGLES, gameObject.model.numIndices, GL_UNSIGNED_INT, (void *)0 );
    
    // 5. Unbind
    glBindVertexArray(0);

}

- (void)drawGameObjectMinimap:(GameObject *)gameObject
{
    GLKMatrix4 mv = GLKMatrix4Multiply(vMap, gameObject.transform.GetModelMatrix);
    
    // uniforms
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)mv.m);
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float *)pMap.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);
    glUniform1i(uniforms[UNIFORM_IS_DAYTIME], isDaytime);
    glUniform1i(uniforms[UNIFORM_IS_FLASHLIGHT_ON], isFlashlightOn);
    glUniform1i(uniforms[UNIFORM_IS_FOG_ON], isFogOn);
    glUniform1i(uniforms[UNIFORM_FOG_MODE], fogMode);
    glUniform1f(uniforms[UNIFORM_FOG_INTENSITY], fogIntensity);
    glUniform1f(uniforms[UNIFORM_IS_MINIMAP], true);
    glUniform1i(uniforms[UNIFORM_IS_OVERLAY], _isOverlay);
    
    // textures
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, gameObject.material.texture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // 3. Bind VAO
    glBindVertexArray(gameObject.model.VAO);
    
    // 4. Draw
    glDrawElements ( GL_TRIANGLES, gameObject.model.numIndices, GL_UNSIGNED_INT, (void *)0 );
    
    // 5. Unbind
    glBindVertexArray(0);
    glUniform1f(uniforms[UNIFORM_IS_MINIMAP], false);
    glUniform1i(uniforms[UNIFORM_IS_OVERLAY], false);
}


// FUNCTIONS: Camera control
-(void)rotateCam :(id)sender {
    UIPanGestureRecognizer * info = (UIPanGestureRecognizer *)sender;
    const float m = 0.5f;
    CGPoint translation = [info translationInView:info.view];
    camXRotation += (translation.y * (m/5));
    camYRotation += (translation.x * (m/5));
    while (camXRotation >=360.0f) {
        camXRotation -= 360.0f;
    }
    while (camYRotation >= 360.f) {
        camYRotation -= 360.0f;
    }
}

-(void)moveCam {
    const float speed = 0.1f;
    GLKVector3 normalForward = GLKVector3Normalize(forward);
    normalForward = GLKVector3Multiply(normalForward, GLKVector3Make(speed, speed, -speed));
    
    camPos = GLKVector3Add(camPos, normalForward);
    //NSLog(@"Position = %f,%f,%f",camPos.x,camPos.y,camPos.z);
}

@end

