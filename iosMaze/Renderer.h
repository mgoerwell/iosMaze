//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>
#import "GameObject.h"

@interface Renderer : NSObject

+ (void)setIsDaytime :(bool)isOn;
+ (bool)getIsDaytime;

+ (void)setIsFlashlightOn :(bool)isOn;
+ (bool)getIsFlashlightOn;

+ (void)setIsFogOn :(bool)isOn;
+ (bool)getIsFogOn;

+ (void)toggleFogMode;
+ (void)setFogIntensity :(float)value;

+ (void)setCameraPosition :(GLKVector3) cameraPos;
+ (GLKVector3)getCameraPosition;

+ (void)setCameraXRotation :(int)camXRot;
+ (void)setCameraYRotation :(int)camYRot;
+ (float)getCameraYRotation;

- (void)setup:(GLKView *)view;
- (void)update;
- (void)drawGameObject:(GameObject*)gameObject;
- (void)drawGameObjectMinimap:(GameObject*)gameObject;
- (void)rotateCam :(id)sender;
- (void)moveCam;

@property float fov;
@property bool isOverlay;

@end

#endif /* Renderer_h */
