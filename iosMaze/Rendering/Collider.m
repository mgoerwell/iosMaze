//
//  Collider.m
//  iosMaze
//
//  Created by Matt Goerwell on 2018-04-04.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Collider.h"

@implementation Collider
int SIZE;

int dest[2];

-(id)init {
    self = [super init];
    if (self)
    {
        _scale = GLKVector3Make(1.0, 1.0, 1.0);
    }
    return self;
}

-(void)DefineMaze :(int)size :(int)x :(int)z{
    SIZE = size;
    _position = GLKVector3Make(x, 0, z);
}

-(void)SetScale:(float)scale {
    _scale = GLKVector3Make(scale, scale, scale);
    _radius = _radius * scale;
}

-(void)Move : (float)x :(float)z {

    if (_position.x != dest[0] || _position.z != dest[1]) {
        float x_mov = x;
        float z_mov = z;
        [self Translate:x_mov :0 :z_mov];
    } else {
        _moving = false;
        _x_pos = dest[0];
        _z_pos = dest[1];
    }
}

-(void)SetDest : (int)x : (int)z {
    if (x < 0 || x > SIZE || z < 0 || z > SIZE) {
        return;
    }
    dest[0] = x;
    dest[1] = z;
    _moving = true;
}

-(void)SetRadius:(float)radius {
    _radius = radius*1.25;
}

-(void)Translate :(float)x :(float)y :(float)z
{
    _position = GLKVector3Make(_position.x + x, _position.y + y, _position.z + z);
}


@end
