//
//  Model.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-19.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h> // for VAO's
#import "Model.h"

@implementation Model : NSObject

// private variables
GLuint vboVertices;
GLuint vboIndices;
uint vertexCount;

// load data directly
-(void)LoadVertexData :(NSMutableArray*)vertexDataArray
                      :(NSMutableArray*)indexArray
{
    struct VertexData vertBuf[vertexDataArray.count];
    for (int i = 0; i<vertexDataArray.count; i++)
    {
        NSValue *read = [vertexDataArray objectAtIndex:i];
        [read getValue:&vertBuf[i]];
    }

    int indices[indexArray.count];
    for (int i = 0; i<indexArray.count; i++)
    {
        indices[i] = [[indexArray objectAtIndex:i] intValue];
    }
    
    int foo = vertexDataArray.count;
    int bar = indexArray.count;
    int foobar = sizeof(vertBuf);
    
    // Create VAO
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    // Create VBO (vertex data)
    glGenBuffers(1, &vboVertices);
    glBindBuffer(GL_ARRAY_BUFFER, vboVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertBuf), vertBuf, GL_STATIC_DRAW);
    
    // bind attributes
    glVertexAttribPointer ( 0, 3, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, position) );
    glEnableVertexAttribArray ( 0 );
    
    glVertexAttribPointer ( 1, 4, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, color) );
    glEnableVertexAttribArray ( 1 );
    
    glVertexAttribPointer ( 2, 3, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, normal) );
    glEnableVertexAttribArray ( 2 );
    
    glVertexAttribPointer ( 3, 2, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, uv) );
    glEnableVertexAttribArray ( 3 );
    
    // Create VBO (index data)
    glGenBuffers(1, &vboIndices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIndices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexArray.count*sizeof(indices[0]), indices, GL_STATIC_DRAW);
}

// functions override
-(void)LoadData:(float *)vertices :(float *)normals :(float *)texCoords :(uint *)indices :(uint)vCount :(uint)iCount
{
    _position = vertices;
    _normal = normals;
    _uv = texCoords;
    _indices = indices;
    vertexCount = vCount;
    _numIndices = iCount;
    [self SetupBuffers];
}

-(void)SetupBuffers
{
    struct VertexData vertBuf[vertexCount];
    
    for (int v=0; v<vertexCount; v++) {
        memcpy(vertBuf[v].position, &_position[v*3], sizeof(vertBuf[0].position));
//        memcpy(vertBuf[v].color, &_color[v*4], sizeof(vertBuf[0].color));
        vertBuf[v].color[0] = 1.0f;
        vertBuf[v].color[1] = 0.0f;
        vertBuf[v].color[2] = 0.0f;
        vertBuf[v].color[3] = 1.0f;
        memcpy(vertBuf[v].normal, &_normal[v*3], sizeof(vertBuf[0].normal));
        memcpy(vertBuf[v].uv, &_uv[v*2], sizeof(vertBuf[0].uv));
    }
    
    // Create VAO
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);

    // Create VBO (vertex data)
    glGenBuffers(1, &vboVertices);
    glBindBuffer(GL_ARRAY_BUFFER, vboVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertBuf), vertBuf, GL_STATIC_DRAW);

    // bind attributes
    glVertexAttribPointer ( 0, 3, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, position) );
    glEnableVertexAttribArray ( 0 );
    
    glVertexAttribPointer ( 1, 4, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, color) );
    glEnableVertexAttribArray ( 1 );
    
    glVertexAttribPointer ( 2, 3, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, normal) );
    glEnableVertexAttribArray ( 2 );
    
    glVertexAttribPointer ( 3, 2, GL_FLOAT,
                           GL_FALSE, sizeof ( vertBuf[0] ),
                           (void *)offsetof(struct VertexData, uv) );
    glEnableVertexAttribArray ( 3 );

    // Create VBO (index data)
    glGenBuffers(1, &vboIndices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIndices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _numIndices*sizeof(_indices[0]), _indices, GL_STATIC_DRAW);

}

// debug data

+(float*)GetCubeVertices
{
    static float cubeVerts[] =
    {
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f, -0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, 0.5f,
        -0.5f,  0.5f, 0.5f,
        0.5f,  0.5f, 0.5f,
        0.5f, -0.5f, 0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
    };
    return cubeVerts;
}

+(float*)GetWallVertices
{
    static float wallVerts[] =
    {
        -0.5f, -0.5f, -0.1f,
        -0.5f, -0.5f,  0.1f,
        0.5f, -0.5f,  0.1f,
        0.5f, -0.5f, -0.1f,
        -0.5f,  0.5f, -0.1f,
        -0.5f,  0.5f,  0.1f,
        0.5f,  0.5f,  0.1f,
        0.5f,  0.5f, -0.1f,
        -0.5f, -0.5f, -0.1f,
        -0.5f,  0.5f, -0.1f,
        0.5f,  0.5f, -0.1f,
        0.5f, -0.5f, -0.1f,
        -0.5f, -0.5f, 0.1f,
        -0.5f,  0.5f, 0.1f,
        0.5f,  0.5f, 0.1f,
        0.5f, -0.5f, 0.1f,
        -0.5f, -0.5f, -0.1f,
        -0.5f, -0.5f,  0.1f,
        -0.5f,  0.5f,  0.1f,
        -0.5f,  0.5f, -0.1f,
        0.5f, -0.5f, -0.1f,
        0.5f, -0.5f,  0.1f,
        0.5f,  0.5f,  0.1f,
        0.5f,  0.5f, -0.1f,
    };
    return wallVerts;
}

+(float*)GetCubeNormals
{
    static float cubeNormals[] =
    {
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, -1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
    };
    return cubeNormals;
}

+(float*)GetCubeUvs
{
    static float cubeTex[] =
    {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    return cubeTex;
}

+(GLuint*)GetCubeIndices
{
    static GLuint cubeIndices[] =
    {
        0, 2, 1,
        0, 3, 2,
        4, 5, 6,
        4, 6, 7,
        8, 9, 10,
        8, 10, 11,
        12, 15, 14,
        12, 14, 13,
        16, 17, 18,
        16, 18, 19,
        20, 23, 22,
        20, 22, 21
    };
    return cubeIndices;
}

@end 
