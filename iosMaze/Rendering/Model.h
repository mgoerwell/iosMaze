//
//  Model.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-19.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

struct VertexData {
    GLfloat position[3];
    GLfloat color[4];
    GLfloat normal[3];
    GLfloat uv[2];
};

@interface Model : NSObject

@property GLuint VAO;
@property float* position;
@property float* color;
@property float* normal;
@property float* uv;
@property uint* indices;
@property int numIndices;

// convenience function to load data arrays
-(void)LoadData :(float*)vertices :(float*)normals :(float*)texCoords :(uint*)indices :(uint)vCount :(uint)iCount;

// call this function after data arrays are set to generate VAO
-(void)SetupBuffers;

// getters for prebuilt data
+(float*)GetCubeVertices;
+(float*)GetCubeNormals;
+(float*)GetCubeUvs;
+(GLuint*)GetCubeIndices;
+(float*)GetWallVertices;

@end
