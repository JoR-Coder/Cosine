//
//  Cosine.m
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-22.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import "Cosine.h"


#define _X1_ 0
#define _Y1_ 1
#define _Z1_ 2

#define _X2_ 3
#define _Y2_ 4
#define _Z2_ 5

@interface Cosine(){
	float rad1, rad2, rad3,
		  rad4, rad5, rad6;
}

@end


@implementation Cosine

-(instancetype)init{
	
	self = [super init];
	
	if (self) {

		self.Predefs = [[Presets alloc] init];
	}
	
	return self;
}


-(void)calculate:(float *)vertices forGrad:(float)grad atAngle:(int)angle{

	rad1 = (self.Predefs.X1 * grad) * RADIAN;
	rad2 = (self.Predefs.Y1 * grad) * RADIAN;

	rad3 = (self.Predefs.X2 * (grad + 180)) * RADIAN;
	rad4 = (self.Predefs.Y2 * (grad + 180)) * RADIAN;

	rad5 = (self.Predefs.Z1 * grad) * RADIAN;

	vertices[_X1_] = cos(rad1) * cos((2*angle) * RADIAN);
	vertices[_Y1_] = sin(rad2) * 0.95; //sin(self.Grad*RADIAN);

	vertices[_X2_] = cos(rad3) * cos(angle * RADIAN);
	vertices[_Y2_] = sin(rad4) * 0.95; //sin((2*self.Grad)*RADIAN);

	vertices[_Z1_] = cos(rad5) * 0.7;
	vertices[_Z2_] = sin(rad5) * 0.7;

}

@end
