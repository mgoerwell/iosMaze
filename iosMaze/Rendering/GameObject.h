//
//  GameObject.m
//  iosMaze
//
//  Created by Jason Cheung on 2018-03-19.
//  Copyright © 2018 Maze Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transform.h"
#import "Model.h"
#import "Material.h"

@interface GameObject : NSObject

@property Transform* transform;
@property Model* model;
@property Material* material;

// creates blank Transform, Model, and Material objects for editing
-(void)CreateEmpty;

@end

