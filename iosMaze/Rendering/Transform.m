//
//  Transform.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-19.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transform.h"

@implementation Transform

-(id)init
{
    self = [super init];
    if (self)
    {
        _scale = GLKVector3Make(1.0, 1.0, 1.0);
    }
    return self;
}

-(GLKMatrix4)GetModelMatrix
{
    GLKMatrix4 m = GLKMatrix4Translate(GLKMatrix4Identity, _position.x, _position.y, _position.z);
    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(_rotation.y), 0.0, 1.0, 0.0 );
    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(_rotation.x), 1.0, 0.0, 0.0 );
    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(_rotation.z), 0.0, 0.0, 1.0 );
    m = GLKMatrix4Scale(m, _scale.x, _scale.y, _scale.z);
    return m;
}

-(void)Translate :(float)x :(float)y :(float)z
{
    _position = GLKVector3Make(_position.x + x, _position.y + y, _position.z + z);
}

-(void)Rotate :(float)xDeg :(float)yDeg :(float)zDeg\
{
    _rotation = GLKVector3Make(_rotation.x + xDeg, _rotation.y + yDeg, _rotation.z + zDeg);
}

-(void)SetScale :(float)scale
{
    _scale = GLKVector3Make(scale, scale, scale);
}


@end
