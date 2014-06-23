//
//  ViewController.m
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-02.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import "ViewController.h"
#import "Cosine.h"

@interface ViewController ()

// TODO: For future reference, check out SWRevealViewController
@property (weak, nonatomic) IBOutlet UIView *SettingsView;
@property (strong, nonatomic) IBOutlet GLKView *GL;


@property (weak, nonatomic) IBOutlet UITextField *ThicknessView;
@property (weak, nonatomic) IBOutlet UITextField *LinesView;

@property (weak, nonatomic) IBOutlet UISlider *ThicknessSlider;
@property (weak, nonatomic) IBOutlet UISlider *LinesSlider;
@property (weak, nonatomic) IBOutlet UISwitch *AnimateSwitch;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property (nonatomic) Cosine *cosinus;

@property (nonatomic) NSMutableDictionary *Settings;
@property (nonatomic) NSMutableArray *Presets;

@property (nonatomic) float Grad, dx, dy;

@property (nonatomic) CGPoint startPoint;

@end

@implementation ViewController

#define MIN_LINES	   16
#define MAX_LINES     360
#define MIN_THICKNESS   0.06
#define MAX_THICKNESS   1.0



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Add SwipeRight from left Edge.
	UIScreenEdgePanGestureRecognizer *swipeRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipedRight:)];
	swipeRight.edges = UIRectEdgeLeft;
	[self.GL addGestureRecognizer:swipeRight];
	
	// Reset settings.
	self.Grad = 0;

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

	int lines = self.cosinus.Predefs.Lines;
	float thickness = self.cosinus.Predefs.Thickness;

	self.ThicknessSlider.minimumValue = MIN_THICKNESS;
	self.ThicknessSlider.maximumValue = MAX_THICKNESS;

	self.ThicknessView.text = [NSString stringWithFormat:@"%1.2f", thickness];
	self.ThicknessSlider.value = thickness;


	self.LinesSlider.minimumValue = MIN_LINES;
	self.LinesSlider.maximumValue = MAX_LINES;

	self.LinesView.text = [@(lines) stringValue];
	self.LinesSlider.value = lines;
}


-(void)loadSettings{

	self.Settings = [[NSMutableDictionary alloc] init];
	[self.Settings setObject:@YES forKey:@"Animate"];
	[self.Settings setObject:@60 forKey:@"Animate speed"];

	self.cosinus = [[Cosine alloc] init];
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


-(void)setLines:(int)lines{

	
	self.cosinus.Predefs.Lines = lines;
	
	self.LinesView.text = [@(lines) stringValue];
	self.LinesSlider.value = lines;
}


-(void)setThickness:(int)thickness{
	
}


#pragma mark - PickerView stuff...

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{

	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

	return self.cosinus.Predefs.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	
	return [self.cosinus.Predefs nameAtIndex:row];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

	[self.cosinus.Predefs usePreset:row];

	int lines = self.cosinus.Predefs.Lines;
	float thickness = self.cosinus.Predefs.Thickness;

	self.ThicknessView.text = [NSString stringWithFormat:@"%1.2f", thickness];
	self.ThicknessSlider.value = thickness;
	
	self.LinesView.text = [@(lines) stringValue];
	self.LinesSlider.value = lines;
	
}



#pragma mark - Delegates for GLKViewController...

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	
	static GLfloat vertices[] = {
		0.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 0.0f
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
	

	int lines = self.cosinus.Predefs.Lines;
	float thickness = self.cosinus.Predefs.Thickness;

	if (self.AnimateSwitch.on) {
		for (float i = self.Grad; i < (self.Grad+lines); i+=thickness ) {

			[self.cosinus calculate:vertices forGrad:i atAngle:self.Grad];
			
			glDrawArrays(GL_LINE_STRIP, 0, 2);
		}
	}else {
		for (float i = 0; i < 360; i+=thickness ) {
			
			[self.cosinus calculate:vertices forGrad:i atAngle:0];

			glDrawArrays(GL_LINE_STRIP, 0, 2);
			// self.paused = YES;
		}
		
	}
	
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribColor);
	
	
}


-(void)glkViewControllerUpdate:(GLKViewController *)controller{

	self.Grad += 2;
	
	if (self.Grad>360) { self.Grad = 0; }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

	UITouch *touch = [touches anyObject];
	self.startPoint = [touch locationInView:self.view];
	NSLog(@"Start -> x: %f, y: %f", self.startPoint.x, self.startPoint.y);

	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	
	CGPoint point = [touch locationInView:self.view];
	self.dx = point.x - self.startPoint.x;
	self.dy = point.y - self.startPoint.y;
	
	self.cosinus.Predefs.Lines += (self.dx*0.1);
	
	NSLog(@"Drag -> x: %f, y: %f", self.dx, self.dy);
	
}


#pragma mark - Controllers

- (IBAction)thicknessChanged:(UISlider *)sender {

	float thickness = sender.value;

	if (thickness < MIN_THICKNESS) {
		thickness = MIN_THICKNESS;
	}
	
	// self.Presets[self.PresetInUse][P_THICKNESS] = @(thickness);
	self.cosinus.Predefs.Thickness = thickness;
	self.ThicknessView.text = [NSString stringWithFormat:@"%1.2f", thickness];
}

- (IBAction)linesChanged:(UISlider *)sender {

	int lines = sender.value;
	
	//self.Presets[self.PresetInUse][P_LINES] = @(lines);
	self.cosinus.Predefs.Lines = lines;
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
