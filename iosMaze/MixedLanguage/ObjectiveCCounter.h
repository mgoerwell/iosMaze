//
//  ObjectiveCCounter.h
//  COMP8051 Assignment1
//
//  Created by Jason Cheung on 2018-02-13.
//  Copyright © 2018 Jason Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>

struct CPlusPlusCounterWrapper;

@interface ObjectiveCCounter : NSObject
{
    @private
    struct CPlusPlusCounterWrapper *cPlusPlusObject;
}

@property (nonatomic) int value;
@property (nonatomic) BOOL useObjC;

- (void) Increment;

@end
