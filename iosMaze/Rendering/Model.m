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
int numIndices;

// functions
-(void)LoadData:(float *)vertices :(float *)normals :(float *)texCoords :(int *)indices
{
    _position = vertices;
    _normal = normals;
    _uv = texCoords;
    _indices = indices;
}

-(void)SetupBuffers
{
    struct VertexData vertBuf[24];
    
    for (int v=0; v<24; v++) {
        memcpy(vertBuf[v].position, &_position[v*3], sizeof(vertBuf[0].position));
        memcpy(vertBuf[v].color, &_color[v*4], sizeof(vertBuf[0].color));
//        vertBuf[v].color[0] = 1.0f;
//        vertBuf[v].color[1] = 0.0f;
//        vertBuf[v].color[2] = 0.0f;
//        vertBuf[v].color[3] = 1.0f;
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
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices*sizeof(_indices[0]), _indices, GL_STATIC_DRAW);

}

@end 
