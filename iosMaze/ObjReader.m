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

-(Model*)Read :(NSString *)fileName
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
    struct VertexData vertBuf[vertexDataArray.count];
    for (int i = 0; i<vertexDataArray.count; i++)
    {
        NSValue *read = [vertexDataArray objectAtIndex:i];
        [read getValue:&vertBuf[i]];
    }
    
    int indexCount = [indexArray count];
    
    // create model to return
    Model* model = [[Model alloc] init];
    [model LoadVertexData:vertBuf :indexArray :vertexCount :indexCount];
    return model;
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
    
    // assume object is smooth (not flat shading)
    struct VertexData vertexData;
    vertexData.position[0] = x;
    vertexData.position[1] = y;
    vertexData.position[2] = z;
    NSValue *value = [NSValue valueWithBytes:&vertexData objCType:@encode(struct VertexData)];
    [vertexDataArray addObject:value];

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
        
        // retrieve indices
        int posIndex = [components[0] intValue];
        int texIndex = [components[1] intValue];
        int nrmIndex = [components[2] intValue];
        
        // retrieve struct (assumes obj is smooth
        struct VertexData vertexData;
        NSValue *read = [vertexDataArray objectAtIndex:posIndex];
        [read getValue:&vertexData];
        
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
        // update VertexDataArray
        NSValue *write = [NSValue valueWithBytes:&vertexData objCType:@encode(struct VertexData)];
        [vertexDataArray replaceObjectAtIndex:posIndex withObject:write];
    }
}

@end
