//
//  ViewController.m
//  c8051intro3
//
//  Created by Borna Noureddin on 2017-12-20.
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "ViewController.h"
#import "ObjectiveCCounter.h"
#import "DisjointSetWrapper.h"
#import "MazeWrapper.h"

@interface ViewController() {
    Renderer *glesRenderer; // ###
    IBOutlet UILabel *transformLabel;
    IBOutlet UILabel *counterLabel;
}
@end


@implementation ViewController

bool isRotating = false; 
float rotationSpeed = 5.0f;
float movementSpeed = 5.0f;
ObjectiveCCounter *counter;
MazeWrapper *maze;

- (IBAction)theButton:(id)sender {
    NSLog(@"You pressed the Button!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ### <<<
    glesRenderer = [[Renderer alloc] init];
    GLKView *view = (GLKView *)self.view;
    [glesRenderer setup:view];
//    [glesRenderer loadModels];
    // ### >>>
    
    // TODO REMOVE
    counter = [[ObjectiveCCounter alloc] init];
    [self updateCounterDisplay];
    
    // Maze creation
    maze = [[MazeWrapper alloc] initWithSize :10 :10];
    [self printMazeData];
    
    [maze create];
    [self printMazeData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// REGION: MAZE

-(void)printMazeData
{
    NSLog(@"===== Maze Data ======");
    for (int x = 0; x < 10; x++)
    {
        for (int y = 0; y < 10; y++)
        {
            struct MazeCellObjC cell = [maze getCell:x :y];
            NSLog(@"Cell x:%d y:%d N:%d E:%d S:%d W:%d", x, y, cell.northWallPresent, cell.eastWallPresent, cell.southWallPresent, cell.westWallPresent);
        }
    }
    NSLog(@"===== end maze data =====");
}

// endregion



// REGION: GLKIT

- (void)update
{
    [glesRenderer update]; // ###
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [glesRenderer draw:rect]; // ###
    [self updateTransformDisplay];
}

// endregion



// REGION: GESTURES

- (IBAction)OnTapGesture:(id)sender {
    glesRenderer.rotating = !glesRenderer.rotating;
}


CGPoint dragInitialPosition;
float xInitialRotation;
float yInitialRotation;

- (IBAction)OnDragGesture:(UIPanGestureRecognizer *)sender {   
    if (glesRenderer.rotating) return;
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // save initial position and rotations
        dragInitialPosition = [sender translationInView:sender.view];
        xInitialRotation = glesRenderer.xRotationAngle;
        yInitialRotation = glesRenderer.yRotationAngle;
    }
    else
    {
        // calculate final displacements
        CGPoint currentPos = [sender translationInView:sender.view];
        float xDisplacement = currentPos.x - dragInitialPosition.x;
        float yDisplacement = currentPos.y - dragInitialPosition.y;
        // rotate
        glesRenderer.xRotationAngle = yInitialRotation + yDisplacement;
        glesRenderer.yRotationAngle = xInitialRotation + xDisplacement;
    }

}

float initialFov;

- (IBAction)OnPinchGesture:(UIPinchGestureRecognizer *)sender {
    
    if (glesRenderer.rotating) return;
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        initialFov = glesRenderer.fov;
    }
    else
    {
        glesRenderer.fov = initialFov / sender.scale;
    }
    
}

GLKVector3 initialPosition;
float moveSpeed = 0.01f;

- (IBAction)OnTwoTouchDragGesture:(UIPanGestureRecognizer *)sender {

    if (glesRenderer.rotating) return;

    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // save initial position and rotations
        dragInitialPosition = [sender translationInView:sender.view];
        initialPosition = GLKVector3Make(glesRenderer.position.x, glesRenderer.position.y, glesRenderer.position.z);
    }
    else
    {
        // calculate final displacements
        CGPoint currentPos = [sender translationInView:sender.view];
        float xDisplacement = currentPos.x - dragInitialPosition.x;
        float yDisplacement = currentPos.y - dragInitialPosition.y;
        // move
        glesRenderer.position = GLKVector3Make(
            initialPosition.x + xDisplacement * moveSpeed,
            initialPosition.y - yDisplacement * moveSpeed,
            initialPosition.z);
    }
}

// endregion

// REGION: UI

- (IBAction)onResetPress:(id)sender {
    glesRenderer.position = GLKVector3Make(0, 0, 0);
    glesRenderer.xRotationAngle = 0;
    glesRenderer.yRotationAngle = 0;
}

- (void)updateTransformDisplay {
    transformLabel.text = [NSString stringWithFormat: @"Position x:%.01f y:%.01f z:%.01f \nAngle x:%.01f y:%.01f z:%.01f",
        glesRenderer.position.x, glesRenderer.position.y, glesRenderer.position.z,
        glesRenderer.xRotationAngle, glesRenderer.yRotationAngle, 0];

}

- (IBAction)onToggleCounterModePress:(id)sender {
    counter.useObjC = !counter.useObjC;
    [self updateCounterDisplay];
}

- (IBAction)onIncrementPress:(id)sender {
    [counter Increment];
    [self updateCounterDisplay];
}

- (void)updateCounterDisplay {
    counterLabel.text = [NSString stringWithFormat: @"%s: %d", counter.useObjC ? "ObjC" : "CPP", counter.value];
}


// endregion

@end
