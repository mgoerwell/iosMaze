//
//  DisjointSetWrapper.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-03.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import "DisjointSetWrapper.h"
#include "DisjointSet.h"

struct DisjointSetWrapperStruct
{
    DisjointSet obj;
};

@implementation DisjointSetWrapper

- (id) init
{
    self = [super init];
    if (self) {
        disjointSetObj = new DisjointSetWrapperStruct;
    }
    return self;
};

@end

