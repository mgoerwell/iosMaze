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

//#import "Material.h"
//#import "GameObject.h"
//#import "Model.h"
//#import "Transform.h"

@interface ViewController() {
    Renderer *glesRenderer; // ###
    Renderer *playerOverlay;
    GameObject *go;
    NSMutableArray *models;
    NSMutableArray *overlay;
    NSMutableArray *gameObjects;
    IBOutlet UILabel *transformLabel;
    IBOutlet UILabel *counterLabel;
    GLKView *glkView;
    int minimapSize;
    bool minimapOn;
}
@end


@implementation ViewController

bool isRotating = false; 
float rotationSpeed = 5.0f;
float movementSpeed = 5.0f;
const int MAZE_SIZE = 5;
ObjectiveCCounter *counter;
MazeWrapper *maze;

// Shared materials
Material* wallBothMat;
Material* wallLefthMat;
Material* wallRightMat;
Material* wallNoneMat;
Material* floorMat;
Material* crateMat;
Material* playerMat;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    models = [NSMutableArray array];
    overlay = [NSMutableArray array];
    gameObjects = [NSMutableArray array];
    
    // ### <<< (Crate)
    glkView = (GLKView *)self.view;
    glesRenderer = [[Renderer alloc] init];
    [glesRenderer setup:glkView];
    [glesRenderer loadModels:MODEL_CUBE];
    [glesRenderer setPosition:GLKVector3Make(MAZE_SIZE / 2, 0, -1)];
 //   glesRenderer.rotating = true;
    // glesRenderer.texture = TEX_CRATE;
    [models addObject:glesRenderer];
    // ### >>>
//
//    // Minimap
//    minimapOn = true;
//    // red player indicator
//    playerOverlay = (GLKView *)self.view;
//    playerOverlay = [[Renderer alloc] init];
//    [playerOverlay setup:(GLKView * )self.view];
//    [playerOverlay loadModels:MODEL_WALL];
//    playerOverlay.xRot = 90;
//    playerOverlay.texture = TEX_BLACK;
//    [overlay addObject:playerOverlay];
//    // black box for minimap
//    [self genOverlay];
//

    [self setupMaterial];
    
    // Maze creation
    maze = [[MazeWrapper alloc] initWithSize :MAZE_SIZE :MAZE_SIZE];
    [maze create];
    [self generateMazeWall];

    // Misc setup
    [self resetCamera];
    [Renderer setFogIntensity:5.0];
    
    
    // SOMETHING NEW
    
    // Standalone GameObject
    go = [[GameObject alloc] init];
    go.transform.position = GLKVector3Make(MAZE_SIZE/2, 0, -1);
    [go.model LoadData:Model.GetCubeVertices
                      :Model.GetCubeNormals
                      :Model.GetCubeUvs
                      :Model.GetCubeIndices
                      :24
                      :36];
    [go.material LoadTexture:@"wallBothSides.jpg"];
    
    Model* cubeModel = [[Model alloc] init];
    Model* wallModel = [[Model alloc] init];
    Material* sharedMat = [[Material alloc] init];
    
    [cubeModel LoadData:Model.GetCubeVertices
                       :Model.GetCubeNormals
                       :Model.GetCubeUvs
                       :Model.GetCubeIndices
                       :24 :36];
    
    [wallModel LoadData:Model.GetWallVertices
                       :Model.GetCubeNormals
                       :Model.GetCubeUvs
                       :Model.GetCubeIndices
                       :24 :36];
    
    [sharedMat LoadTexture:@"wallNoSides.jpg"];
    
    GameObject* go2 = [[GameObject alloc] init];
    go2.transform = [[Transform alloc] init];
    go2.transform.position = GLKVector3Make(MAZE_SIZE/2 - 1, 0.5, -1);
    go2.model = cubeModel;
    go2.material = sharedMat;
    
    GameObject* go3 = [[GameObject alloc] init];
    go3.transform = [[Transform alloc] init];
    go3.transform.position = GLKVector3Make(MAZE_SIZE/2 + 1, 0.5, -1);
    go3.model = wallModel;
    go3.material = sharedMat;
    
    [gameObjects addObject:go];
    [gameObjects addObject:go2];
    [gameObjects addObject:go3];
}

- (void)setupMaterial
{
    wallBothMat = [[Material alloc] init];
    wallNoneMat = [[Material alloc] init];
    wallLefthMat = [[Material alloc] init];
    wallRightMat = [[Material alloc] init];
    floorMat = [[Material alloc] init];
    crateMat = [[Material alloc] init];
    
    [wallBothMat LoadTexture:@"wallBothSides.jpg"];
    [wallNoneMat LoadTexture:@"wallNoSides.jpg"];
    [wallLefthMat LoadTexture:@"wallLeftSide.jpg"];
    [wallRightMat LoadTexture:@"wallRightSide.jpg"];
    [floorMat LoadTexture:@"floor.jpg"];
    [crateMat LoadTexture:@"crate.jpg"];
    [playerMat LoadTexture:@"red.jpg"];
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
    // create a shared model for all wall objects
    Model* wallModel = [[Model alloc] init];
    [wallModel LoadData:Model.GetWallVertices
                       :Model.GetCubeNormals
                       :Model.GetCubeUvs
                       :Model.GetCubeIndices
                       :24 :36];
    
    for (int x = 0; x < MAZE_SIZE; x++)
    {
        for (int y = 0; y < MAZE_SIZE; y++)
        {
            struct MazeCellObjC cell = [maze getCell:x :y];
            
            if (cell.northWallPresent)
            {
                int rightTexture = 0;
                rightTexture = [self wallCheckNorth:y column:x];

                GameObject* go = [[GameObject alloc] init];
                go.transform.position = GLKVector3Make(x, 0, y + 0.4);
                go.model = wallModel;
                [self selectTexture:go selection:rightTexture];

                [gameObjects addObject:go];
            }
            
            if (cell.eastWallPresent)
            {
                int rightTexture = 0;
                rightTexture = [self wallCheckEast:y column:x];

                GameObject* go = [[GameObject alloc] init];
                go.transform.position = GLKVector3Make(x + 0.4, 0, y);
                go.model = wallModel;
                [self selectTexture:go selection:rightTexture];
                
                [gameObjects addObject:go];
            }
            
            if (cell.southWallPresent)
            {
                int rightTexture = 0;
                rightTexture = [self wallCheckSouth:y column:x];

                GameObject* go = [[GameObject alloc] init];
                go.transform.position = GLKVector3Make(x, 0, y - 0.4);
                go.model = wallModel;
                [self selectTexture:go selection:rightTexture];
                
                [gameObjects addObject:go];
            }
            
            if (cell.westWallPresent)
            {
                int rightTexture = 0;
                rightTexture = [self wallCheckWest:y column:x];

                GameObject* go = [[GameObject alloc] init];
                go.transform.position = GLKVector3Make(x - 0.4, 0, y);
                go.model = wallModel;
                [self selectTexture:go selection:rightTexture];
                
                [gameObjects addObject:go];
            }
            
            GameObject* go = [[GameObject alloc] init];
            go.transform.position = GLKVector3Make(x, -0.6, y);
            go.transform.rotation = GLKVector3Make(90, 0, 0);
            go.model = wallModel;
            go.material = floorMat;
            [gameObjects addObject:go];
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
- (void)selectTexture:(GameObject *)go
              selection:(int)selection
{
    switch (selection) {
        case 0:
            go.material = wallBothMat;
            break;
        case 1:
            go.material = wallLefthMat;
            break;
        case 2:
            go.material = wallRightMat;
            break;
        default:
            go.material = wallNoneMat;
            break;
    }
}

// endregion


// REGION: Minimap

- (void)genOverlay
{
    for (int x = -5; x < MAZE_SIZE + 5; x++)
    {
        for (int y = -5; y < MAZE_SIZE + 5; y++)
        {
            Renderer *r = [[Renderer alloc] init];
            [r setup:(GLKView * )self.view];
            [r loadModels:MODEL_WALL];
            r.position = GLKVector3Make(x, -2.0, y);
            r.xRot = 90;
            r.isOverlay = true;
            [overlay addObject:r];
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
    
    // minimap
    if (!minimapOn) return;
    
    for (int i = 0; i < overlay.count; i++)
    {
        [((Renderer *)overlay[i]) update];
    }
    GLKVector3 camPos = [Renderer getCameraPosition];
    camPos.y = 2.0f;  // always on top of map
    playerOverlay.position = camPos;
    playerOverlay.yRot = -[Renderer getCameraYRotation];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // clean up
    glViewport(0, 0, (int)self->glkView.drawableWidth, (int)self->glkView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    // [glesRenderer draw:rect];
    for (int i = 0; i < gameObjects.count; i++)
    {
        [glesRenderer drawGameObject:((GameObject*)gameObjects[i])];
    }
    
    return;
    
    // draw
    for (int i = 0; i < models.count; i++)
    {
        [((Renderer *)models[i]) draw:rect];
    }
    
    // MINIMAP
    if (!minimapOn) return;
    
    int w = (int)(self->glkView.drawableWidth / 2);
    int h = (int)(self->glkView.drawableHeight / 2);
    minimapSize = (w < h) ? w : h;
    
    glViewport(((int)(self->glkView.drawableWidth)) - minimapSize,
               ((int)(self->glkView.drawableHeight)) - minimapSize,
               minimapSize, minimapSize);

    // clear depth for section
    glEnable(GL_SCISSOR_TEST);
    glScissor(((int)(self->glkView.drawableWidth)) - minimapSize,
               ((int)(self->glkView.drawableHeight)) - minimapSize,
               minimapSize, minimapSize);
    glClear(GL_DEPTH_BUFFER_BIT);
    glDisable(GL_SCISSOR_TEST);

    // make transparent
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_SRC_ALPHA);
    
    // draw minimap
    for (int i = 0; i < models.count; i++)
    {
        [((Renderer *)models[i]) drawMinimap];
    }
    for (int i = 0; i < overlay.count; i++)
    {
        [((Renderer *)overlay[i]) drawMinimap];
    }
    glDisable(GL_BLEND);
    
}

-(void)resetCamera {
    [Renderer setCameraPosition:GLKVector3Make(MAZE_SIZE / 2, 0, -3)];
    [Renderer setCameraYRotation:180];
    [Renderer setCameraXRotation:0];
}

// endregion



// REGION: GESTURES

CGPoint dragInitialPosition;
float xInitialRotation;
float yInitialRotation;

- (IBAction)OnDragGesture:(UIPanGestureRecognizer *)sender {   
    //if (glesRenderer.rotating) return;
    
    [glesRenderer rotateCam:sender];
    

}

- (IBAction)DoubleTap:(id)sender {
    UITapGestureRecognizer * info = (UITapGestureRecognizer *) sender;
    if (info.numberOfTouches == 1) {
        [self resetCamera];
    }
}

- (IBAction)DoubleDoubleTap:(id)sender {
    minimapOn = !minimapOn;
}

- (IBAction)Pinch:(id)sender {
    [glesRenderer moveCam];
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
