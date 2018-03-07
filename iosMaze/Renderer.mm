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
    UNIFORM_TEXTURE,
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
    GLuint crateTexture;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;

    GLKMatrix4 mvp;
    GLKMatrix3 normalMatrix;

    GLuint vertArr; // VAO that 'contains' the VBO's
    GLuint vbo;     // VBO that contains pos, color, normal, uv.
    GLuint idxBuf;  // VBO that contains index data
    
    float rotAngle;
    float rotSpeed;

    float *vertices, *normals, *texCoords;
    int *indices, numIndices;
}

@end

@implementation Renderer



// REGION: ADDITIONS

@synthesize xRotationAngle = _xRotationAngle;
- (float)xRotationAngle
{
    return _xRotationAngle;
}
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
    
    [self setupBuffer];
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
    
    // setup texture and buffers
    [self loadModels];
    [self setupBuffer];
    crateTexture = [self setupTexture:@"crate.jpg"];
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

// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
// Sample code to demonstrate difference between vertex arrays. single and multiple VBOs
//
// (c) Borna Noureddin, BCIT
//
//////////////////////////////////////////////////////////////////////////////////////////

// Use exactly 0 or 1 of the #define's below (commenting out both means use single VBO)
- (void)draw:(CGRect)drawRect;
{
    // clean up
    glViewport(0, 0, (int)theView.drawableWidth, (int)theView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glUseProgram ( programObject );

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

    // uniforms
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);
    
    // textures
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // vao
    glBindVertexArray(vertArr);
    
    // draw
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, (void *)0 );

    // unbind
    glBindVertexArray(0);
}

-(void) setupBuffer
{
    // ----- Translate individual array data to VBO data ------
    struct glVertStruct {
        GLfloat position[3];
        GLfloat color[4];
        GLfloat normal[3];
        GLfloat uv[2];
    };

    struct glVertStruct vertBuf[24];

    for (int v=0; v<24; v++) {
        memcpy(vertBuf[v].position, &vertices[v*3], sizeof(vertBuf[0].position));
        vertBuf[v].color[0] = 1.0f;
        vertBuf[v].color[1] = 0.0f;
        vertBuf[v].color[2] = 0.0f;
        vertBuf[v].color[3] = 1.0f;
        memcpy(vertBuf[v].normal, &normals[v*3], sizeof(vertBuf[0].normal));
        memcpy(vertBuf[v].uv, &texCoords[v*2], sizeof(vertBuf[0].uv));
    }
    
    // Create VAO
    glGenVertexArrays(1, &vertArr);
    glBindVertexArray(vertArr);
    
    // Create Vertex VBO
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertBuf), vertBuf, GL_STATIC_DRAW);
    
    // bind attributes
    glVertexAttribPointer ( 0, 3, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(glVertStruct, position) );
    glEnableVertexAttribArray ( 0 );
    
    glVertexAttribPointer ( 1, 4, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(glVertStruct, color) );
    glEnableVertexAttribArray ( 1 );
    
    glVertexAttribPointer ( 2, 3, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(glVertStruct, normal) );
    glEnableVertexAttribArray ( 2 );
    
    glVertexAttribPointer ( 3, 2, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(glVertStruct, uv) );
    glEnableVertexAttribArray ( 3 );

    // ----- Translate index data to VBO data -----
    // Create Index VBO
    glGenBuffers(1, &idxBuf);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, idxBuf);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices*sizeof(indices[0]), indices, GL_STATIC_DRAW);
}


@end

