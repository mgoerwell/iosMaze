//
//  MazeWrapper.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-04.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import "MazeWrapper.h"
#include "maze.h"

struct MazeWrapperStruct
{
    Maze *obj;
};

@implementation MazeWrapper

// OVERRIDES
-(id)initWithSize :(int)rows :(int)cols
{
    self = [super init];
    if (self) {
        mazeObj = new MazeWrapperStruct;
        mazeObj->obj = new Maze(rows, cols);
    }
    return self;
};

-(int)rows
{
    return mazeObj->obj->rows;
};

-(int)cols
{
    return mazeObj->obj->cols;
};

-(MazeCellObjC)getCell :(int)x :(int)y
{
    MazeCell cObj = mazeObj->obj->GetCell(x, y);
    return [self convertMazeCell:cObj];
};

-(void)create
{
    mazeObj->obj->Create();
};

// HELPERS
-(MazeCellObjC)convertMazeCell :(MazeCell)mazeCell
{
    MazeCellObjC objC;
    objC.northWallPresent = mazeCell.northWallPresent;
    return objC;
}

@end


