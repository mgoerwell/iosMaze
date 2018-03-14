//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>

typedef enum
{
    TEX_FLOOR,
    TEX_WALL_BOTH,
    TEX_WALL_RIGHT,
    TEX_WALL_LEFT,
    TEX_WALL_NO,
    TEX_CRATE,
    NUM_TEXTURES
} TextureType;

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
- (GLuint)setupTexture:(NSString *)fileName;


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
@property GLuint texture;


@end

#endif /* Renderer_h */
