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
    UNIFORM_FLASHLIGHT_DIR,
    UNIFORM_FLASHLIGHT_POS,
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
    
    // debug variables
    GLKVector3 camPos;
    float camXRot, camYRot;
}
@end


@implementation Renderer

// STATIC VARIABLES
static bool isDaytime;
static bool isFlashlightOn;
static bool isFogOn;

// STATIC GETTERS/SETTERS
+(void)setIsDaytime :(bool)isOn { isDaytime = isOn; }
+(bool)getIsDaytime { return isDaytime; }

+(void)setIsFlashlightOn :(bool)isOn { isFlashlightOn = isOn; }
+(bool)getIsFlashlightOn { return isFlashlightOn; }

+(void)setIsFogOn :(bool)isOn { isFogOn = isOn; }
+(bool)getIsFogOn { return isFogOn; }

// PROPERTIES
@synthesize xRot = _xRot;
- (float)xRot { return _xRot; }
- (void)setXRot :(float)newRot
{
    if (newRot > 360.0f)     _xRot = newRot - 360.0f;
    else if (newRot < 0.0f)  _xRot = newRot + 360.0f;
    else                     _xRot = newRot;
}

@synthesize yRot = _yRot;
- (float)yRot { return _yRot; }
- (void)setYRot :(float)newRot
{
    if (newRot > 360.0f)     _yRot = newRot - 360.0f;
    else if (newRot < 0.0f)  _yRot = newRot + 360.0f;
    else                     _yRot = newRot;
}

// FUNCTIONS: VIEW
- (void)dealloc
{
    glDeleteProgram(programObject);
}

// FUNCTIONS: INITIALIZATION
// Use this after [init] to instantiate to default values
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
    self.rotating = false;
    self.fov = 60.0f;
    self.position = GLKVector3Make(0, 0, 0);
    
    camPos = GLKVector3Make(0,0,-5);
    camXRot = 0;
    camYRot = 0;
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
    glEnable(GL_DEPTH_TEST);
    lastTime = std::chrono::steady_clock::now();
    
    // setup texture and buffers
    [self loadModels];
    [self setupBuffer];
    crateTexture = [self setupTexture:@"crate.jpg"];
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
    uniforms[UNIFORM_FLASHLIGHT_DIR] = glGetUniformLocation(programObject, "u_flashlightDir");
    uniforms[UNIFORM_FLASHLIGHT_POS] = glGetUniformLocation(programObject, "u_flashlightPos");
    
    return true;
}

// TODO: Used to load vertex data (only handles rectangular model right now)
- (void)loadModels
{
    numIndices = glesRenderer.GenWall(1.0f, &vertices, &normals, &texCoords, &indices);
    [self setupBuffer];
}

// Call to create and bind VAO's and VBO's. Only call this after raw vertex data has been loaded (eg. [self loadModels])
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

// FUNCTIONS: GLKIT UPDATING & DRAWING
// Update object
- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto deltaTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();
    lastTime = currentTime;
    
    if (self.rotating)
    {
        self.yRot += 0.01f * deltaTime;
    }
}

// Draw this object
- (void)draw:(CGRect)drawRect;
{
    glUseProgram ( programObject );

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

    // 1. Calculate matrices
    // View
    // Note; Might want to use translate and rotation for camera. Using this function to test flashlight/fog.
    GLKMatrix4 v = GLKMatrix4MakeLookAt(3, 1, -3,   // cam pos
                         0, 0, 0,                   // target pos
                         0, 1, 0);                  // up dir
    
    GLKVector3 flashlightPos = GLKVector3Make(v.m30, v.m31, v.m32); // cam position (this is also the flightlight position);
    GLKVector3 flashlightDir = GLKVector3Make(v.m20, v.m21, v.m22); // cam forward (this is also the flashlight direction)
    
    // Model
    GLKMatrix4 m = GLKMatrix4Translate(GLKMatrix4Identity, self.position.x, self.position.y, self.position.z);
    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(self.yRot), 0.0, 1.0, 0.0 );
    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(self.xRot), 1.0, 0.0, 0.0 );
    
    GLKMatrix4 mv = GLKMatrix4Multiply(v, m);
    
    // Projection
    float aspect = (float)theView.drawableWidth / (float)theView.drawableHeight;
    GLKMatrix4 p = GLKMatrix4MakePerspective(self.fov * M_PI / 180.0f, aspect, 1.0f, 20.0f);
    
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
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_DIR], 1, flashlightDir.v);
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POS], 1, flashlightPos.v);
    
    // textures
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    // 3. Bind VAO
    glBindVertexArray(vertArr);
    
    // 4. Draw
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, (void *)0 );

    // 5. Unbind
    glBindVertexArray(0);
}




@end

