//
//  MazeWrapper.h
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-04.
//  Copyright © 2018 Maze Team. All rights reserved.
//
//  This class is essentially an adapter for the Maze c++ class.
//  Wrapper (ObjC) > Struct (ObjC) > Object pointer (* C++) > Object (C++)
//

#ifndef MazeWrapper_h
#define MazeWrapper_h
#import <Foundation/Foundation.h>

struct MazeCellObjC
{
    bool northWallPresent, southWallPresent, eastWallPresent, westWallPresent;
};

struct MazeWrapperStruct;

@interface MazeWrapper : NSObject

// Fields
{
@private struct MazeWrapperStruct *mazeObj;
}

// Functions
-(id)initWithSize :(int)rows :(int)cols;
-(int)rows;
-(int)cols;
-(struct MazeCellObjC)getCell :(int)x :(int)y;
-(void)create;

@end

#endif /* MazeWrapper_h */

