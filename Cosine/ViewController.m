//
//  ViewController.m
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-02.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *SettingsView;
@property (strong, nonatomic) IBOutlet GLKView *GL;


@property (weak, nonatomic) IBOutlet UITextField *ThicknessView;
@property (weak, nonatomic) IBOutlet UITextField *LinesView;

@property (weak, nonatomic) IBOutlet UISlider *ThicknessSlider;
@property (weak, nonatomic) IBOutlet UISlider *LinesSlider;
@property (weak, nonatomic) IBOutlet UISwitch *AnimateSwitch;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property (nonatomic) NSMutableDictionary *Settings;
@property (nonatomic) NSMutableArray *Presets;
@property (nonatomic) int PresetInUse;

@property (nonatomic) float Grad;

@end

@implementation ViewController

#define RADIAN          0.0174539252
#define MAX_LINES     360
#define MIN_THICKNESS   0.06
#define MAX_THICKNESS   1.0

#define X1 0
#define Y1 1
#define Z1 2
#define X2 3
#define Y2 4
#define Z2 5

#define P_NAME      0
#define P_X1		1
#define P_Y1		2
#define P_Z1		3
#define P_X2		4
#define P_Y2		5
#define P_Z2		6
#define P_LINES     7
#define P_THICKNESS 8

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIScreenEdgePanGestureRecognizer *swipeRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipedRight:)];
	swipeRight.edges = UIRectEdgeLeft;
	[self.GL addGestureRecognizer:swipeRight];
	
	
	self.Grad = 0;
	self.PresetInUse = 0;

	[self setupSettings];
	[self setupGL];
}

-(void)viewDidAppear:(BOOL)animated{
	CGRect f =  self.SettingsView.frame;
	
	// Hide the panel.
	f.origin.x = -472;
	self.SettingsView.frame = f;

}



#pragma mark - Setup'n'stuff...

-(void)setupSettings{

	[self loadSettings];
	
	if ([[self.Settings objectForKey:@"Animate"] boolValue]==1) {
		self.AnimateSwitch.on = YES;
	}else{
		self.AnimateSwitch.on = NO;
	}

	self.ThicknessSlider.value = [[self.Settings objectForKey:@"Thickness"] floatValue];
	self.ThicknessSlider.minimumValue = MIN_THICKNESS;
	self.ThicknessSlider.maximumValue = MAX_THICKNESS;
	self.ThicknessView.text = [[self.Settings objectForKey:@"Thickness"] stringValue];
	self.LinesSlider.value = [[self.Settings objectForKey:@"Lines"] intValue];
	self.LinesSlider.maximumValue = MAX_LINES;
	self.LinesView.text = [[self.Settings objectForKey:@"Lines"] stringValue];
	
}


-(void)loadSettings{

	self.Settings = [[NSMutableDictionary alloc] init];
	[self.Settings setObject:@90  forKey:@"Lines"];
	[self.Settings setObject:@60  forKey:@"Animate speed"];
	[self.Settings setObject:@0.5 forKey:@"Thickness"];
	[self.Settings setObject:@YES forKey:@"Animate"];
//	[self.Settings setObject:@64 forKey:@"Lines"];
/*	[self.Settings setObject:@64 forKey:@"Lines"];
	[self.Settings setObject:@64 forKey:@"Lines"];
	[self.Settings setObject:@64 forKey:@"Lines"];
	*/

	self.Presets = [[NSMutableArray alloc] init];

	//																			  x1   y1  z1  x2  y2  z2  lin  thick
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Mysti1",   @1,  @2, @1, @2, @1, @1, @64, @0.15]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Mysti2",   @2,  @1, @1, @1, @2, @1, @32, @0.10]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple1",   @3,  @1, @1, @3, @1, @1, @90, @0.24]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple2",   @2,  @3, @1, @3, @2, @1, @90, @0.25]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple3",   @3,  @3, @1, @2, @2, @1, @360, @0.55]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple4",   @3,  @3, @1, @1, @1, @1, @275, @0.60]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Apple5",   @3,  @2, @1, @1, @2, @1, @90, @0.2]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Diamond1", @2,  @2, @2, @3, @3, @2, @360, @0.5]] ];
	[self.Presets addObject:[[NSMutableArray alloc] initWithArray:@[ @"Diamond2", @2,  @2, @2, @3, @3, @2, @90, @0.25]] ];
	
}


-(void)setupGL{
	self.ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if (!self.ctx) {
		NSLog(@"Failed to create ES context.");
		
		return;
	}
	
	self.preferredFramesPerSecond = (int)self.Settings[@"Animate speed"];
	self.GL.context = self.ctx;
	self.delegate = self;
	
	self.GL.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
	self.GL.drawableDepthFormat = GLKViewDrawableDepthFormat16;
	self.GL.drawableStencilFormat = GLKViewDrawableStencilFormat8;
	
	self.effect = [[GLKBaseEffect alloc] init];
	self.effect.useConstantColor = GL_TRUE;
	self.effect.constantColor = GLKVector4Make(0.2f, 0.2f, 0.9f, 1.0f);
	
	
}


#pragma mark - PickerView stuff...

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return self.Presets.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [self.Presets objectAtIndex:row][0];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	self.PresetInUse = row;
}



#pragma mark - Delegates for GLKViewController...

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	
	static GLfloat vertices[] = {
		-1.0f, -1.0f, 1.0,
		 0.2f,  0.2,  1.0
	};
	
	static const GLubyte colors[] = {
		0, 255, 255, 125,
		0,   0, 255,   0
	};
	
	[self.effect prepareToDraw];
	
	glClearColor( 0.2, 0.2, 0.9, 1.0 );
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	glClear(GL_STENCIL_BUFFER_BIT);
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribColor);
	
	glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
	glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, colors);
	
	glEnable(GL_BLEND);
	glEnable(GL_LINE_SMOOTH_HINT);
	
	glLineWidth(1.0f);
	
	//int lines = [[self.Settings objectForKey:@"Lines"] intValue];
	int lines =       [self.Presets[self.PresetInUse][P_LINES] intValue];
	float thickness = [self.Presets[self.PresetInUse][P_THICKNESS] floatValue];

	if (self.AnimateSwitch.on) {
		for (float i = self.Grad; i < (self.Grad+lines); i+=thickness ) {
			
			float rad1 = ([self.Presets[self.PresetInUse][P_X1] floatValue]*i)*RADIAN;
			float rad2 = ([self.Presets[self.PresetInUse][P_Y1] floatValue]*i)*RADIAN;
			float rad3 = ([self.Presets[self.PresetInUse][P_X2] floatValue]*i)*RADIAN;
			float rad4 = ([self.Presets[self.PresetInUse][P_Y2] floatValue]*i)*RADIAN;
			float rad5 = ([self.Presets[self.PresetInUse][P_Z1] floatValue]*i)*RADIAN;

			vertices[X1] = cos(rad1)*cos((2*self.Grad)*RADIAN);
			vertices[Y1] = sin(rad2)*0.95; //sin(self.Grad*RADIAN);
			vertices[X2] = cos(rad3)*cos(self.Grad*RADIAN);
			vertices[Y2] = sin(rad4)*0.95; //sin((2*self.Grad)*RADIAN);
			vertices[Z1] = cos(rad5)*0.7;
			vertices[Z2] = sin(rad5)*0.7;
			
			glRotatef(self.Grad, 0.2, 0.9, 0.1);
			glDrawArrays(GL_LINE_STRIP, 0, 2);
		}
	}else {
		for (float i = 0; i < 360; i+=thickness ) {
			
			float rad1 = [self.Presets[self.PresetInUse][P_X1] floatValue]*i*RADIAN;
			float rad2 = [self.Presets[self.PresetInUse][P_Y2] floatValue]*i*RADIAN;
			float rad3 = [self.Presets[self.PresetInUse][P_X2] floatValue]*i*RADIAN;
			float rad4 = [self.Presets[self.PresetInUse][P_Y2] floatValue]*i*RADIAN;
			float rad5 = [self.Presets[self.PresetInUse][P_Z1] floatValue]*i*RADIAN;
			
			vertices[X1] = cos(rad1)*cos(RADIAN);
			vertices[Y1] = sin(rad2)*0.95;
			vertices[X2] = cos(rad3)*0.95;
			vertices[Y2] = sin(rad4)*sin(RADIAN);
			vertices[Z1] = cos(rad5)*0.3;
			vertices[Z2] = sin(rad5)*0.3;
			
			glDrawArrays(GL_LINE_STRIP, 0, 2);
			self.paused = YES;
		}
		
	}
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribColor);
	
	
}


-(void)glkViewControllerUpdate:(GLKViewController *)controller{

	self.Grad += 2;
	
	if (self.Grad>360) { self.Grad = 0; }
}



#pragma mark - Controllers

- (IBAction)thicknessChanged:(UISlider *)sender {
	float thickness = sender.value;
	if (thickness < MIN_THICKNESS) {
		thickness = MIN_THICKNESS;
	}
	
	// [self.Settings setObject:[NSNumber numberWithFloat:thickness] forKey:@"Thickness"];
	self.ThicknessView.text = [NSString stringWithFormat:@"%1.2f", thickness];
	self.Presets[self.PresetInUse][P_THICKNESS] = @(thickness);

}

- (IBAction)linesChanged:(UISlider *)sender {
	int lines = sender.value;
	
	self.Presets[self.PresetInUse][P_LINES] = @(lines);
	self.LinesView.text = [@(lines) stringValue];
}

- (IBAction)animateSwitched:(UISwitch *)sender {
	
	[self.Settings setObject:[NSNumber numberWithBool:sender.on] forKey:@"Animate"];
	
	if (sender.on) { self.paused = NO; }
}



-(void)userSwipedRight:(UIScreenEdgePanGestureRecognizer *) recognizer{
	CGPoint location = [recognizer locationInView:self.parentViewController.view];
	CGRect f =  self.SettingsView.frame;

	
	if (f.origin.x==0) { return; }

	if (recognizer.state == UIGestureRecognizerStateChanged){
		f.origin.x = -472 + location.x;
		
		self.SettingsView.frame = f;
		
	} else if (recognizer.state == UIGestureRecognizerStateEnded){
		//NSLog(@"Swiped ended at: x=%f, v=%f", location.x, velocity.x);

		if( f.origin.x < -300 ){
			f.origin.x = -472;
			[UIView animateWithDuration:0.2 animations:^{
				self.SettingsView.frame = f;
			} completion:nil ];
		} else{
			f.origin.x = 0;
			[UIView animateWithDuration:0.2 animations:^{
				self.SettingsView.frame = f;
			} completion:nil ];
		}
		
	}
}


- (IBAction)closePanelGesture:(UISwipeGestureRecognizer *)sender {
	
	if (sender.direction == UISwipeGestureRecognizerDirectionLeft ) {
		CGRect f =  self.SettingsView.frame;
		
		// Hide the panel.
		f.origin.x = -472;

		[UIView animateWithDuration:0.3 animations:^{
			self.SettingsView.frame = f;
			} completion:nil ];
	}
}



@end
