//
//  Presets.m
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-22.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import "Presets.h"


#define _NAME_ 0

#define _X1_ 1
#define _Y1_ 2
#define _Z1_ 3

#define _X2_ 4
#define _Y2_ 5
#define _Z2_ 6

#define _LINES_     7
#define _THICKNESS_ 8


@interface Presets()

@property (nonatomic) NSMutableArray *List;

@property (nonatomic) int Selected;

@end


@implementation Presets


-(instancetype)init{
	
	self = [super init];
	
	if (self) {

		self.Selected = 0;

		[self loadPresets];
	}

	return self;
}



-(void)loadPresets{
	// But for now, use hardcoded ones...
	self.List = [[NSMutableArray alloc] init];
	
	//																		   x1   y1  z1  x2  y2  z2  lin   thick
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Default",  @1,  @2, @2, @1, @1, @1,  @64, @0.35]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Mysti1",   @1,  @2, @1, @2, @1, @1,  @64, @0.15]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Mysti2",   @2,  @1, @1, @1, @2, @1,  @32, @0.10]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple1",   @3,  @1, @1, @3, @1, @1,  @90, @0.24]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple2",   @2,  @3, @1, @3, @2, @1,  @90, @0.25]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple3",   @3,  @3, @1, @2, @2, @1, @360, @0.55]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple4",   @3,  @3, @1, @1, @1, @1, @275, @0.60]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple5",   @3,  @2, @1, @1, @2, @1,  @90, @0.2 ]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Diamond1", @2,  @2, @2, @3, @3, @2, @360, @0.5 ]] ];
	[self.List addObject:[[NSMutableArray alloc] initWithArray:@[ @"Diamond2", @2,  @2, @2, @3, @3, @2,  @90, @0.25]] ];

	// Set all the properties...
	self.Name = self.List[self.Selected][_NAME_];

	self.X1 = [self.List[self.Selected][_X1_] floatValue];
	self.Y1 = [self.List[self.Selected][_Y1_] floatValue];
	self.Z1 = [self.List[self.Selected][_Z1_] floatValue];

	self.X2 = [self.List[self.Selected][_X2_] floatValue];
	self.Y2 = [self.List[self.Selected][_X2_] floatValue];
	self.Z2 = [self.List[self.Selected][_Z2_] floatValue];

	self.Lines = [self.List[self.Selected][_LINES_] integerValue];
	self.Thickness = [self.List[self.Selected][_THICKNESS_] floatValue];
	
	_count = self.List.count;
}


-(void)savePresets{
	// TODO: Add implementation
}


-(void)addPreset{
	// TODO: Add implementation
}


-(void)removePreset:(int)index{
	// TODO: Add implementation
}


-(void)usePreset:(int)index{

	self.Selected = index;
	
	// Set all the properties...
	self.Name = self.List[self.Selected][_NAME_];
	
	self.X1 = [self.List[self.Selected][_X1_] floatValue];
	self.Y1 = [self.List[self.Selected][_Y1_] floatValue];
	self.Z1 = [self.List[self.Selected][_Z1_] floatValue];
	
	self.X2 = [self.List[self.Selected][_X2_] floatValue];
	self.Y2 = [self.List[self.Selected][_X2_] floatValue];
	self.Z2 = [self.List[self.Selected][_Z2_] floatValue];
	
	self.Lines = [self.List[self.Selected][_LINES_] integerValue];
	self.Thickness = [self.List[self.Selected][_THICKNESS_] floatValue];

}


-(NSArray*)getArrayList{
	// TODO: Add implementation
	return nil;
}


-(NSString *)nameAtIndex:(int)index{
	if(index >= 0 && index <= self.List.count)
		return self.Name = self.List[index][_NAME_];
	else
		return @"Out of bound.";
}

@end
