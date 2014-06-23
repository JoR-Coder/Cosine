//
//  Cosine.h
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-22.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Presets.h"

#define RADIAN          0.0174539252

@interface Cosine : NSObject

@property (nonatomic) Presets *Predefs;

-(void)calculate:(float *)vertices forGrad:(float)grad atAngle:(int)angle;

@end
