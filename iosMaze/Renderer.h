//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>

@interface Renderer : NSObject

+ (void)setIsDaytime :(bool)isOn;
+ (void)setIsFlashlightOn :(bool)isOn;
+ (void)setIsFogOn :(bool)isOn;
+ (bool)getIsDaytime;
+ (bool)getIsFlashlightOn;
+ (bool)getIsFogOn;
- (void)setCameraPosition :(GLKVector3) cameraPos;
- (void)setCameraXRotation :(int)camXRot;
- (void)setCameraYRotation :(int)camYRot;

- (void)setup:(GLKView *)view;
- (void)loadModels;
- (void)update;
- (void)draw:(CGRect)drawRect;
- (void)moveCam :(id)sender;

@property bool rotating;
@property float yRot;
@property float xRot;
@property float fov;
@property GLKVector3 position;


@end

#endif /* Renderer_h */
