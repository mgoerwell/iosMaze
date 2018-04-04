//
//  GameObject.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-19.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@implementation GameObject : NSObject

-(id) init
{
    self = [super init];
    if (self)
    {
        _transform = [[Transform alloc] init];
        _model     = [[Model alloc] init];
        _material  = [[Material alloc] init];
    }
    return self;
}

@end 

