//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>
#import "GameObject.h"

typedef enum
{
    TEX_FLOOR,
    TEX_WALL_BOTH,
    TEX_WALL_RIGHT,
    TEX_WALL_LEFT,
    TEX_WALL_NO,
    TEX_CRATE,
    TEX_BLACK,
    NUM_TEXTURES
} TextureType;

typedef enum
{
    MODEL_CUBE,
    MODEL_WALL,
    MODEL_OVERLAY
} ModelType;

@interface Renderer : NSObject

+ (void)setIsDaytime :(bool)isOn;
+ (void)setIsFlashlightOn :(bool)isOn;
+ (void)setIsFogOn :(bool)isOn;
+ (bool)getIsDaytime;
+ (bool)getIsFlashlightOn;
+ (bool)getIsFogOn;
+ (void)toggleFogMode;
+ (void)setFogIntensity :(float)value;
+ (void)setCameraPosition :(GLKVector3) cameraPos;
+ (void)setCameraXRotation :(int)camXRot;
+ (void)setCameraYRotation :(int)camYRot;
+ (GLKVector3)getCameraPosition;
+ (float)getCameraYRotation;

- (GLuint)setupTexture:(NSString *)fileName;
- (void)setup:(GLKView *)view;
- (void)loadModels :(int)type;
- (void)update;
- (void)draw:(CGRect)drawRect;
- (void)drawGameObject:(GameObject*)gameObject;
- (void)drawGameObjectMinimap:(GameObject*)gameObject;
- (void)drawMinimap;
- (void)rotateCam :(id)sender;
- (void)moveCam;

@property bool rotating;
@property float yRot;
@property float xRot;
@property float fov;
@property GLKVector3 position;
@property GLuint texture;
@property bool isOverlay;


@end

#endif /* Renderer_h */
