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
const int MAZE_SIZE = 5;
ObjectiveCCounter *counter;
MazeWrapper *maze;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    models = [NSMutableArray array];
    
    // ### <<< (Debug object)
    glkView = (GLKView *)self.view;
    glesRenderer = [[Renderer alloc] init];
    [glesRenderer setup:glkView];
    glesRenderer.rotating = true;
    glesRenderer.texture = TEX_CRATE;
    // [glesRenderer loadModels];
    // ### >>>
    
    // Maze creation
    maze = [[MazeWrapper alloc] initWithSize :MAZE_SIZE :MAZE_SIZE];
    [maze create];
    [self printMazeData];

    [self generateMazeWall];
    [models addObject:glesRenderer];
    
    // Misc setup
    [Renderer setFogIntensity:5.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// REGION: MAZE

-(void)printMazeData
{
    NSLog(@"===== Maze Data ======");
    for (int x = 0; x < MAZE_SIZE; x++)
    {
        for (int y = 0; y < MAZE_SIZE; y++)
        {
            struct MazeCellObjC cell = [maze getCell:x :y];
            NSLog(@"Cell x:%d y:%d N:%d E:%d S:%d W:%d", x, y, cell.northWallPresent, cell.eastWallPresent, cell.southWallPresent, cell.westWallPresent);
        }
    }
    NSLog(@"===== end maze data =====");
}

-(void)generateMazeWall
{
    
    for (int x = 0; x < MAZE_SIZE; x++)
    {
        for (int y = 0; y < MAZE_SIZE; y++)
        {
            struct MazeCellObjC cell = [maze getCell:x :y];
            
            if (cell.northWallPresent)
            {
                int rightTexture = 0;
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                // r.position = GLKVector3Make(x, 0, y + 0.4);
                rightTexture = [self wallCheckNorth:y column:x];
                [self selectTexture:r selection:rightTexture];
                [models addObject:r];
            }
            
            if (cell.eastWallPresent)
            {
                int rightTexture = 0;
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                r.position = GLKVector3Make(x + 0.4, 0, y);
                r.yRot = 90;
                rightTexture = [self wallCheckEast:y column:x];
                [self selectTexture:r selection:rightTexture];
                [models addObject:r];
            }
            
            if (cell.southWallPresent)
            {
                int rightTexture = 0;
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                r.position = GLKVector3Make(x, 0, y - 0.4);
                rightTexture = [self wallCheckSouth:y column:x];
                [self selectTexture:r selection:rightTexture];
                [models addObject:r];
            }
            
            if (cell.westWallPresent)
            {
                int rightTexture = 0;
                Renderer *r = [[Renderer alloc] init];
                [r setup:(GLKView * )self.view];
                r.position = GLKVector3Make(x - 0.4, 0, y);
                r.yRot = 90;
                rightTexture = [self wallCheckWest:y column:x];
                [self selectTexture:r selection:rightTexture];
                [models addObject:r];
            }
            
            Renderer *r = [[Renderer alloc] init];
            [r setup:(GLKView * )self.view];
            r.position = GLKVector3Make(x, -0.6, y);
            r.xRot = 90;
            r.texture = TEX_FLOOR;
            [models addObject:r];
        }
    }
}

- (int)wallCheckNorth:(int)row
                column:(int)column {
    //bools for determining adjacency
    bool wallLeft = false;
    bool wallRight = false;
    
    //boundary check
    if (column - 1 < 0) {}
    else if ([maze getCell:column - 1 :row].northWallPresent) {//check cell to our left
        wallLeft = true;
    }
    
    if (column + 1 >= MAZE_SIZE) {}
    else if ([maze getCell:column + 1 :row].northWallPresent) {//check cell to our right
        wallRight = true;
    }
    
    if (wallLeft && wallRight){return 0;} // both walls
    if (wallLeft) {return 1;} //left wall only
    if (wallRight) {return 2;} // right wall only
    return 3; //no walls adjacent
}

- (int)wallCheckWest:(int)row
               column:(int)column {
    //bools for determining adjacency
    bool wallLeft = false;
    bool wallRight = false;
    
    //boundary check
    if (row - 1 < 0) {}
    else if ([maze getCell:column :row - 1].westWallPresent) {//check cell to our right
        wallRight = true;
    }
    
    if (row + 1 >= MAZE_SIZE) {}
    else if ([maze getCell:column :row + 1].westWallPresent) {//check cell to our left
        wallLeft = true;
    }
    
    if (wallLeft && wallRight){return 0;} // both walls
    if (wallLeft) {return 1;} //left wall only
    if (wallRight) {return 2;} // right wall only
    return 3; //no walls adjacent
}

- (int)wallCheckEast:(int)row
               column:(int)column {
    //bools for determining adjacency
    bool wallLeft = false;
    bool wallRight = false;
    
    //boundary check
    if (row - 1 < 0) {}
    else if ([maze getCell:column :row - 1].eastWallPresent) {//check cell to our left (up)
        wallLeft = true;
    }
    
    if (row + 1 >= MAZE_SIZE) {}
    else if ([maze getCell:column :row + 1].eastWallPresent) {//check cell to our right
        wallRight = true;
    }
    
    if (wallLeft && wallRight){return 0;} // both walls
    if (wallLeft) {return 1;} //left wall only
    if (wallRight) {return 2;} // right wall only
    return 3; //no walls adjacent
}

- (int)wallCheckSouth:(int)row
               column:(int)column {
    //bools for determining adjacency
    bool wallLeft = false;
    bool wallRight = false;
    
    //boundary check
    if (column - 1 < 0) {}
    else if ([maze getCell:column - 1 :row].southWallPresent) {//check cell to our left
        wallRight = true;
    }
    
    if (column + 1 >= MAZE_SIZE) {}
    else if ([maze getCell:column + 1 :row].southWallPresent) {//check cell to our right
        wallLeft = true;
    }
    
    if (wallLeft && wallRight){return 0;} // both walls
    if (wallLeft) {return 1;} //left wall only
    if (wallRight) {return 2;} // right wall only
    return 3; //no walls adjacent
}

//convert selected texture to actual image for texture
- (void)selectTexture:(Renderer *)r
              selection:(int)selection {
    switch (selection) {
        case 0:
            r.texture = TEX_WALL_BOTH;
            break;
        case 1:
            r.texture = TEX_WALL_LEFT;
            break;
        case 2:
            r.texture = TEX_WALL_RIGHT;
            break;
        default:
            r.texture = TEX_WALL_NO;
            break;
    }
//    if (selection == 0) {return [r setupTexture:@"wallBothSides.jpg"];}
//    if (selection == 1) {return [r setupTexture:@"wallLeftSide.jpg"];}
//    if (selection == 2) {return [r setupTexture:@"wallRightSide.jpg"];}
//    return [r setupTexture:@"wallNoSides.jpg"];
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
    for (int i = 0; i < models.count; i++)
    {
        [((Renderer *)models[i]) draw:rect];
    }
}

// endregion



// REGION: GESTURES

CGPoint dragInitialPosition;
float xInitialRotation;
float yInitialRotation;

- (IBAction)OnDragGesture:(UIPanGestureRecognizer *)sender {   
    if (glesRenderer.rotating) return;
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // save initial position and rotations
        dragInitialPosition = [sender translationInView:sender.view];
        xInitialRotation = glesRenderer.xRot;
        yInitialRotation = glesRenderer.yRot;
    }
    else
    {
        // calculate final displacements
        CGPoint currentPos = [sender translationInView:sender.view];
        float xDisplacement = currentPos.x - dragInitialPosition.x;
        float yDisplacement = currentPos.y - dragInitialPosition.y;
        // rotate
        glesRenderer.xRot = yInitialRotation + yDisplacement;
        glesRenderer.yRot = xInitialRotation + xDisplacement;
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
    [Renderer toggleFogMode];
}

- (IBAction)onFogIntensityChange:(UIStepper*)sender {
    NSLog([NSString stringWithFormat:@"Fog Intensity: %f", sender.value]);
    [Renderer setFogIntensity: sender.value];
}

// endregion

@end
