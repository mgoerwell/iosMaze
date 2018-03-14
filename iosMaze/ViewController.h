	//
//  ViewController.h
//  c8051intro3
//
//  Created by Borna Noureddin on 2017-12-20.
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Renderer.h" // ###

//@interface ViewController : UIViewController
@interface ViewController : GLKViewController // ###
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapRcognizer;

@end

