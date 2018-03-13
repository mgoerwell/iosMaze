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

- (void)setup:(GLKView *)view;
- (void)loadModels;
- (void)update;
- (void)draw:(CGRect)drawRect;

@property bool rotating;
@property float yRotationAngle;
@property float xRotationAngle;
@property float fov;
@property GLKVector3 position;

@end

#endif /* Renderer_h */
