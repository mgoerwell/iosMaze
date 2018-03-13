//
//  ObjectiveCCounter.m
//  COMP8051 Assignment1
//
//  Created by Jason Cheung on 2018-02-13.
//  Copyright © 2018 Jason Cheung. All rights reserved.
//

#import "ObjectiveCCounter.h"
#include "CPlusPlusCounter.h"



struct CPlusPlusCounterStruct
{
    CPlusPlusCounter obj;
};



@implementation ObjectiveCCounter

@synthesize value;
@synthesize useObjC;

- (id) init
{
    self = [super init];
    if (self) {
        useObjC = YES;
        value = 0;
        cPlusPlusObject = new CPlusPlusCounterStruct;
    }
    return self;
};

- (int) value
{
    return useObjC ? value : cPlusPlusObject->obj.GetValue();
};

- (void) Increment {
    if (useObjC) {
        value++;
    } else {
        cPlusPlusObject->obj.Increment();
    }
};

@end
