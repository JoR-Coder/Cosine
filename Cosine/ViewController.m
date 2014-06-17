//
//  ViewController.m
//  Cosine
//
//  Created by Jyrki Rajala on 2014-06-02.
//  Copyright (c) 2014 Jyrki Rajala. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    GLuint _program;


}

@property (weak, nonatomic) IBOutlet UIView *SettingsView;
@property (strong, nonatomic) IBOutlet GLKView *RootView;
@property (weak, nonatomic) IBOutlet GLKView *GL;

@property (weak, nonatomic) IBOutlet UITextField *ThicknessView;
@property (weak, nonatomic) IBOutlet UITextField *LinesView;

@property (weak, nonatomic) IBOutlet UISlider *ThicknessSlider;
@property (weak, nonatomic) IBOutlet UISlider *LinesSlider;
@property (weak, nonatomic) IBOutlet UISwitch *AnimateSwitch;

@property (strong, nonatomic) GLKBaseEffect *effect;

@property (nonatomic) NSMutableDictionary *Settings;

@property (nonatomic) float Grad;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIScreenEdgePanGestureRecognizer *swipeRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipedRight:)];
	swipeRight.edges = UIRectEdgeLeft;
	[self.RootView addGestureRecognizer:swipeRight];
	
	
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



-(void)setupSettings{
	[self loadSettings];
	
	if ([[self.Settings objectForKey:@"Animate"] boolValue]==1) {
		self.AnimateSwitch.on = YES;
	}else{
		self.AnimateSwitch.on = NO;
	}
	self.ThicknessSlider.value = [[self.Settings objectForKey:@"Thickness"] floatValue]/10;
	self.ThicknessView.text = [[self.Settings objectForKey:@"Thickness"] stringValue];
	self.LinesSlider.value = [[self.Settings objectForKey:@"Lines"] floatValue]/64;
	self.LinesView.text = [[self.Settings objectForKey:@"Lines"] stringValue];
	
}


-(void)loadSettings{
	self.Settings = [[NSMutableDictionary alloc] init];
	[self.Settings setObject:[NSNumber numberWithInt:63] forKey:@"Lines"];
	[self.Settings setObject:[NSNumber numberWithInt:60] forKey:@"Animate speed"];
	[self.Settings setObject:[NSNumber numberWithFloat:5] forKey:@"Thickness"];
	[self.Settings setObject:[NSNumber numberWithBool:YES] forKey:@"Animate"];
/*	[self.Settings setObject:@64 forKey:@"Lines"];
	[self.Settings setObject:@64 forKey:@"Lines"];
	[self.Settings setObject:@64 forKey:@"Lines"];
	[self.Settings setObject:@64 forKey:@"Lines"];
	*/
	
}

- (IBAction)thicknessChanged:(UISlider *)sender {
	float thickness = sender.value*10;
	if (thickness<=0.05) {
		thickness = 0.05;
	}
	
	[self.Settings setObject:[NSNumber numberWithFloat:thickness] forKey:@"Thickness"];
	self.ThicknessView.text = [@(thickness) stringValue];
}

- (IBAction)linesChanged:(UISlider *)sender {
	int lines = sender.value*64;
	[self.Settings setObject:[NSNumber numberWithFloat:lines] forKey:@"Lines"];
	self.LinesView.text = [@(lines) stringValue];
}

- (IBAction)animateSwitched:(UISwitch *)sender {
	BOOL animate = sender.on;
	[self.Settings setObject:[NSNumber numberWithBool:animate] forKey:@"Animate"];
	if (animate) {
		self.paused = NO;
	} else {
		// [self glkView:self.GL drawInRect:self.GL.frame];
		
		//self.paused = YES;

	}
}

-(void)setupGL{
	self.ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if (!self.ctx) {
		NSLog(@"Failed to create ES context.");
	}

	self.preferredFramesPerSecond = (int)self.Settings[@"Animate speed"];
	self.GL.context = self.ctx;
	self.delegate = self;

	// Configure renderbuffers created by the view
   self.GL.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
   self.GL.drawableDepthFormat = GLKViewDrawableDepthFormat16;
   self.GL.drawableStencilFormat = GLKViewDrawableStencilFormat8;

	self.effect = [[GLKBaseEffect alloc] init];
	self.effect.useConstantColor = GL_TRUE;
	self.effect.constantColor = GLKVector4Make(0.2f, 0.2f, 0.9f, 1.0f);


}


-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{

	static GLfloat Vertices[] = {
		-1.0f, -1.0f, 1.0,
		0.2f,  0.2,  1.0
		//	-0.5f,  0.5f, 1,
		//	 0.5f,  0.5f, 1
	};
	
	static const GLubyte Colors[] = {
		  0, 255, 255, 125,
		  0,   0, 255,   0,
		  0, 255,   0, 255,
		255,   0, 255, 255
	};
	
	[self.effect prepareToDraw];
	
	glClearColor( 0.2, 0.2, 0.9, 1.0 );
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	glClear(GL_STENCIL_BUFFER_BIT);
	
	
	//	GLfloat line_vertex[] = { -0.6f, -0.6f, 0.5f, 0.5f };
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribColor);
	
	glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, Vertices);
	glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, Colors);
	
	glEnable(GL_BLEND);
	glEnable(GL_LINE_SMOOTH);
	
	glLineWidth(2.0f);
	
	Vertices[4] = 0.1;

	int lines = [[self.Settings objectForKey:@"Lines"] intValue];
	float thickness = [[self.Settings objectForKey:@"Thickness"] floatValue];

	if (self.AnimateSwitch.on) {
		for (float i = self.Grad; i < (self.Grad+lines); i+=thickness ) {
			
			Vertices[0] = cos((1*i)*(M_PI/180))*cos((3*self.Grad)*(M_PI/180));
			Vertices[1] = sin((3*i)*(M_PI/180))*0.95;
			Vertices[3] = cos((3*i)*(M_PI/180))*0.95;
			Vertices[4] = sin((1*i)*(M_PI/180))*sin((1*self.Grad)*(M_PI/180));
			Vertices[2] = cos(i*(M_PI/180))*0.3;
			
			glDrawArrays(GL_LINE_STRIP, 0, 2);
		}
	}else {
		for (float i = 0; i < 360; i+=thickness ) {
			
			Vertices[0] = cos((1*i)*(M_PI/180))*cos((3*self.Grad)*(M_PI/180));
			Vertices[1] = sin((3*i)*(M_PI/180))*0.95;
			Vertices[3] = cos((3*i)*(M_PI/180))*0.95;
			Vertices[4] = sin((1*i)*(M_PI/180))*sin((1*self.Grad)*(M_PI/180));
			Vertices[2] = cos(i*(M_PI/180))*0.3;
			
			glDrawArrays(GL_LINE_STRIP, 0, 2);
			self.paused = YES;
		}
	
	}
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribColor);
	
	
}


-(void)glkViewControllerUpdate:(GLKViewController *)controller{

	if (self.Grad>360) {
		self.Grad = 0;
	}

	self.Grad += 2;
}


-(void)userSwipedRight:(UIScreenEdgePanGestureRecognizer *) recognizer{
	CGPoint location = [recognizer locationInView:self.parentViewController.view];
//	CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
	CGRect f =  self.SettingsView.frame;

	
	if (f.origin.x==0) {
		return;
	}

	if (recognizer.state == UIGestureRecognizerStateBegan) {
		// NSLog(@"Swiped x=%f", location.x);
		
	} else if (recognizer.state == UIGestureRecognizerStateChanged){
		//NSLog(@"Swiped changed: x=%f, v=%f", location.x, velocity.x);

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
		
	} else if (recognizer.state == UIGestureRecognizerStateCancelled){
		//NSLog(@"Swipe cancelled at: x=%f, v=%f", location.x, velocity.x);
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
