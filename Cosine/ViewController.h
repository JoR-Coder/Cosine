//
//  ViewController.h
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-02.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <GLKit/GLKViewController.h>

#import <UIKit/UIScreenEdgePanGestureRecognizer.h>

@interface ViewController : GLKViewController <GLKViewDelegate, GLKViewControllerDelegate>

@property (strong, nonatomic) EAGLContext *ctx;

@end
