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
    NSMutableArray *models;
    IBOutlet UILabel *transformLabel;
    IBOutlet UILabel *counterLabel;
    GLKView *glkView;
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
    
    models = [NSMutableArray array];
    
    // ### <<<
    glkView = (GLKView *)self.view;
    glesRenderer = [[Renderer alloc] init];
    [glesRenderer setup:glkView];
    glesRenderer.rotating = true;
    //    [glesRenderer loadModels];
    // ### >>>
    
    // TODO REMOVE
    counter = [[ObjectiveCCounter alloc] init];
    [self updateCounterDisplay];
    
    // Maze creation
    maze = [[MazeWrapper alloc] initWithSize :10 :10];
    [maze create];
    [self printMazeData];

    [self generateMazeWall];
    [models addObject:glesRenderer];
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

-(void)generateMazeWall
{
    for (int x = 0; x < 10; x++)
    {
        for (int y = 0; y < 10; y++)
        {
            struct MazeCellObjC cell = [maze getCell:x :y];
            
            if (cell.northWallPresent)
            {
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                // r.position = GLKVector3Make(x, 0, y + 0.4);
                [models addObject:r];
            }
            
            if (cell.eastWallPresent)
            {
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                r.position = GLKVector3Make(x + 0.4, 0, y);
                r.yRotationAngle = 90;
                [models addObject:r];
            }
            
            if (cell.southWallPresent)
            {
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                r.position = GLKVector3Make(x, 0, y - 0.4);
                [models addObject:r];
            }
            
            if (cell.westWallPresent)
            {
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                r.position = GLKVector3Make(x - 0.4, 0, y);
                r.yRotationAngle = 90;
                [models addObject:r];
            }
        }
    }
}

// endregion



// REGION: GLKIT

- (void)update
{
    for (int i = 0; i < models.count; i++)
    {
        [((Renderer *)models[i]) update];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // clean up
    glViewport(0, 0, (int)self->glkView.drawableWidth, (int)self->glkView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    // draw
//     [glesRenderer draw:rect]; // ###
    [self updateTransformDisplay];
    
    for (int i = 0; i < models.count; i++)
    {
        [((Renderer *)models[i]) draw:rect];
    }
}

// endregion



// REGION: GESTURES

- (IBAction)OnTapGesture:(id)sender {
    // toggle day
    [Renderer setIsDaytime:![Renderer getIsDaytime]];
    
    // glesRenderer.rotating = !glesRenderer.rotating;
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
- (IBAction)onDayNightPress:(id)sender {
    [Renderer setIsDaytime: ![Renderer getIsDaytime]];
}
- (IBAction)onFlashlightPress:(id)sender {
    [Renderer setIsFlashlightOn: ![Renderer getIsFlashlightOn]];
}
- (IBAction)onFogPress:(id)sender {
    [Renderer setIsFogOn: ![Renderer getIsFogOn]];
}

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
