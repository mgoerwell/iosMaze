//
//  ObjReader.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-28.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjReader.h"
#import "Model.h"

@implementation ObjReader

// private
NSMutableArray *vertices;
NSMutableArray *uvs;
NSMutableArray *normals;

// public
NSMutableArray *vertexDataArray;
NSMutableArray *indexArray;

-(id)init
{
    self = [super init];
    if (self)
    {
        vertices = [NSMutableArray array];
        uvs = [NSMutableArray array];
        normals = [NSMutableArray array];
        vertexDataArray = [NSMutableArray array];
        indexArray = [NSMutableArray array];
    }
    return self;
}

-(void)Read :(NSString *)fileName
{
    // clear all arrays
    
    NSString *path = [NSBundle.mainBundle pathForResource:fileName ofType:@"obj"];
    NSError *error;

    if ([path length] != 0)
    {
        NSString* data = [NSString
                          stringWithContentsOfFile:path
                          encoding:NSUTF8StringEncoding
                          error:&error];
        NSArray *lines = [data componentsSeparatedByString:@"\n"];

        for (int i = 0; i < [lines count]; i++)
        {
            if ([lines[i] hasPrefix:@"v "])
            {
                [self ReadVertex:lines[i]];
            }
            else if ([lines[i] hasPrefix:@"vt "])
            {
                [self ReadUV:lines[i]];
            }
            else if ([lines[i] hasPrefix:@"vn "])
            {
                [self ReadNormal:lines[i]];
            }
            else if ([lines[i] hasPrefix:@"f "])
            {
                [self ReadFace:lines[i]];
            }
            else
            {
                // unknown line
            }
        }
    }
    // data reading complete
    
    // compile data
    int vertexCount = [vertexDataArray count];
    struct VertexData vertBuf[];

    // create model to return
    Model* model = [[Model alloc] init];

}

-(void)ReadVertex :(NSString*)line
{
    NSArray *strings = [line componentsSeparatedByString:@" "];
    
    float x = [strings[1] floatValue];
    float y = [strings[2] floatValue];
    float z = [strings[3] floatValue];
    
    [vertices addObject:[NSNumber numberWithFloat:x]];
    [vertices addObject:[NSNumber numberWithFloat:y]];
    [vertices addObject:[NSNumber numberWithFloat:z]];
}

-(void)ReadUV :(NSString*)line
{
    NSArray *strings = [line componentsSeparatedByString:@" "];
    
    float u = [strings[1] floatValue];
    float v = [strings[2] floatValue];
    
    [uvs addObject:[NSNumber numberWithFloat:u]];
    [uvs addObject:[NSNumber numberWithFloat:v]];
}

-(void)ReadNormal :(NSString*)line
{
    NSArray *strings = [line componentsSeparatedByString:@" "];
    
    float nx = [strings[1] floatValue];
    float ny = [strings[2] floatValue];
    float nz = [strings[3] floatValue];
    
    [normals addObject:[NSNumber numberWithFloat:nx]];
    [normals addObject:[NSNumber numberWithFloat:ny]];
    [normals addObject:[NSNumber numberWithFloat:nz]];
}

-(void)ReadFace :(NSString*)line
{
    NSArray *strings = [line componentsSeparatedByString:@" "];

    // skip first word - "f "
    for (int i = 1; i < [strings count]; i++)
    {
        NSArray *components = [line componentsSeparatedByString:@"/"];
        
        // create struct
        struct VertexData vertexData;
        
        // retrieve indices
        int posIndex = [components[0] intValue];
        int texIndex = [components[1] intValue];
        int nrmIndex = [components[2] intValue];
        
        // construct vertex data
        vertexData.position[0] = [vertices[posIndex*3] floatValue];
        vertexData.position[1] = [vertices[posIndex*3+1] floatValue];
        vertexData.position[2] = [vertices[posIndex*3+2] floatValue];
        vertexData.uv[0]       = [uvs[texIndex*2] floatValue];
        vertexData.uv[1]       = [uvs[texIndex*2+1] floatValue];
        vertexData.normal[0]   = [normals[nrmIndex*3] floatValue];
        vertexData.normal[1]   = [normals[nrmIndex*3+1] floatValue];
        vertexData.normal[2]   = [normals[nrmIndex*3+2] floatValue];

        // add to VertexDataArray and IndexArray (order matters)
        [indexArray addObject:[NSNumber numberWithInt:[vertexDataArray count]]];
        
        NSValue *value = [NSValue valueWithBytes:&vertexData objCType:@encode(struct VertexData)];
        [vertexDataArray addObject:value];
    }
    
//    // To add your struct value to a NSMutableArray
//    NSValue *value = [NSValue valueWithBytes:&structValue objCType:@encode(MyStruct)];
//    [array addObject:value];
//
//    // To retrieve the stored value
//    MyStruct structValue;
//    NSValue *value = [array objectAtIndex:0];
//    [value getValue:&structValue];

}

//-(GLKMatrix4)GetModelMatrix
//{
//    GLKMatrix4 m = GLKMatrix4Translate(GLKMatrix4Identity, _position.x, _position.y, _position.z);
//    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(_rotation.y), 0.0, 1.0, 0.0 );
//    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(_rotation.x), 1.0, 0.0, 0.0 );
//    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(_rotation.z), 0.0, 0.0, 1.0 );
//    m = GLKMatrix4Scale(m, _scale.x, _scale.y, _scale.z);
//    return m;
//}

@end
