//
//  Presets.h
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-22.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Presets : NSObject
// x1   y1  z1  x2  y2  z2  lin  thick

@property (nonatomic) NSString *Name;

@property (nonatomic) float X1;
@property (nonatomic) float Y1;
@property (nonatomic) float Z1;

@property (nonatomic) float X2;
@property (nonatomic) float Y2;
@property (nonatomic) float Z2;

@property (nonatomic) int Lines;
@property (nonatomic) float Thickness;

@property (nonatomic, readonly) int count;
-(instancetype)init;

-(void)loadPresets;
-(void)savePresets;

-(void)addPreset;
-(void)removePreset:(int)index;
-(void)usePreset:(int)index;

-(NSArray*)getArrayList;

-(NSString*)nameAtIndex:(int)index;

@end

