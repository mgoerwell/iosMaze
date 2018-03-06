//
//  DisjointSetWrapper.h
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-03.
//  Copyright © 2018 Maze Team. All rights reserved.
//
//  This class is essentially an adapter for the DisjointSet c++ class.
//  Wrapper (ObjC) > Struct (ObjC) > Object pointer (* C++) > Object (C++)
//  This class is currently NOT being used.
//


#ifndef DisjointSetWrapper_h
#define DisjointSetWrapper_h

#import <Foundation/Foundation.h>

struct DisjointSetWrapperStruct;

@interface DisjointSetWrapper : NSObject
{
@public
    struct DisjointSetWrapperStruct *disjointSetObj;
}

@end


#endif /* DisjointSetWrapper_h */
