//
//  Material.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-19.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Material : NSObject

// float r,g,b,a;
@property GLuint texture;

-(void)LoadTexture :(NSString *)filename;

@end
