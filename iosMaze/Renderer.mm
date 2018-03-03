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
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASSTHROUGH,
    UNIFORM_SHADEINFRAG,
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

@interface Renderer () {
    GLKView *theView;
    GLESRenderer glesRenderer;
    GLuint programObject;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;

    GLKMatrix4 mvp;
    GLKMatrix3 normalMatrix;

    float rotAngle;
    float rotSpeed;

    float *vertices, *normals, *texCoords;
    int *indices, numIndices;
}

@end

@implementation Renderer



// REGION: ADDITIONS

// must explicitly declare if getter is defined
@synthesize xRotationAngle = _xRotationAngle;
// must be defined if setter is defined
- (float)xRotationAngle
{
    return _xRotationAngle;
}
// note: automatic setter
- (void)setXRotationAngle:(float)xRotationAngle
{
    if (xRotationAngle > 360.0f)
        _xRotationAngle = xRotationAngle - 360.0f;
    else if (xRotationAngle < 0.0f)
        _xRotationAngle = xRotationAngle + 360.0f;
    else
        _xRotationAngle = xRotationAngle;
}

@synthesize yRotationAngle = _yRotationAngle;

- (float)yRotationAngle
{
    return _yRotationAngle;
}

- (void)setYRotationAngle:(float)yRotationAngle
{
    if (yRotationAngle > 360.0f)
        _yRotationAngle = yRotationAngle - 360.0f;
    else if (yRotationAngle < 0.0f)
        _yRotationAngle = yRotationAngle + 360.0f;
    else
        _yRotationAngle = yRotationAngle;
}

// endregion



- (void)dealloc
{
    glDeleteProgram(programObject);
}



- (void)loadModels
{
    numIndices = glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices);
}

- (void)setup:(GLKView *)view
{
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!view.context) {
        NSLog(@"Failed to create ES context");

        view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    theView = view;
    [EAGLContext setCurrentContext:view.context];
    if (![self setupShaders])
    {
        NSLog(@"Failed to setup shaders");
        return;
    }
    
    rotAngle = 0.0f;
    rotSpeed = 0.001f;
    self.rotating = true;
    self.fov = 60.0f;
    self.position = GLKVector3Make(0, 0, 0);
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
    glEnable(GL_DEPTH_TEST);
    lastTime = std::chrono::steady_clock::now();
}

- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto deltaTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();
    lastTime = currentTime;
    
    if (self.rotating)
    {
        self.yRotationAngle += 0.01f * deltaTime;
    }

    // View
    mvp = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -5.0);
    
    // Model
    mvp = GLKMatrix4Translate(mvp, self.position.x, self.position.y, self.position.z);
    mvp = GLKMatrix4Rotate(mvp, GLKMathDegreesToRadians(self.yRotationAngle), 0.0, 1.0, 0.0 );
    mvp = GLKMatrix4Rotate(mvp, GLKMathDegreesToRadians(self.xRotationAngle), 1.0, 0.0, 0.0 );
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvp), NULL);

    // Perspective
    float aspect = (float)theView.drawableWidth / (float)theView.drawableHeight;
    GLKMatrix4 perspective = GLKMatrix4MakePerspective(self.fov * M_PI / 180.0f, aspect, 1.0f, 20.0f);

    mvp = GLKMatrix4Multiply(perspective, mvp);
}

- (void)draw:(CGRect)drawRect;
{
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);

    glViewport(0, 0, (int)theView.drawableWidth, (int)theView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glUseProgram ( programObject );

    glVertexAttribPointer ( 0, 3, GL_FLOAT,
                           GL_FALSE, 3 * sizeof ( GLfloat ), vertices );
    glEnableVertexAttribArray ( 0 );
    glVertexAttrib4f ( 1, 1.0f, 0.0f, 0.0f, 1.0f );
    glVertexAttribPointer ( 2, 3, GL_FLOAT,
                           GL_FALSE, 3 * sizeof ( GLfloat ), normals );
    glEnableVertexAttribArray ( 2 );
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices );
}

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
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");

    return true;
}

@end

