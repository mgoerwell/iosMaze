//
//  Collider.h
//  iosMaze
//
//  Created by Matt Goerwell on 2018-04-04.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Collider : NSObject
@property GLKVector3 position;
@property GLKVector3 scale;
@property bool moving;
@property int x_pos;
@property int z_pos;
@property float radiusX;
@property float radiusZ;

-(void)SetScale :(float)scale;
-(void)Translate :(float)x :(float)y :(float)z;
-(void)DefineMaze :(int)size :(int)x :(int)z;
-(void)Move : (float)x :(float)z;
-(void)SetDest : (int)x : (int)z;


@end
