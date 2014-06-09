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
@property (weak, nonatomic) IBOutlet UIView *AnimationView;
@property (strong, nonatomic) IBOutlet UIView *RootView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	UIScreenEdgePanGestureRecognizer *swipeRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(userSwipedRight:)];
	swipeRight.edges = UIRectEdgeLeft;
	[self.RootView addGestureRecognizer:swipeRight];


}

-(void)viewDidAppear:(BOOL)animated{
	CGRect f =  self.SettingsView.frame;
	
	// Hide the panel.
	f.origin.x = -480;
	self.SettingsView.frame = f;
}


-(void)userSwipedRight:(UIScreenEdgePanGestureRecognizer *) recognizer{
	CGPoint location = [recognizer locationInView:self.parentViewController.view];
	CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
	CGRect f =  self.SettingsView.frame;

	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		NSLog(@"Swiped x=%f", location.x);
	} else if (recognizer.state == UIGestureRecognizerStateChanged){
		NSLog(@"Swiped changed: x=%f, v=%f", location.x, velocity.x);

		//if (f.origin.x>=240) {
		//	f.origin.x=240;
			
		//} else if( f.origin.x>=240 && velocity.x<0 ) {
		//	f.origin.x = -240 + location.x;
		//} else {
		f.origin.x = -480 + location.x;
		//}
		
		self.SettingsView.frame = f;
		
	} else if (recognizer.state == UIGestureRecognizerStateEnded){
		NSLog(@"Swiped ended at: x=%f, v=%f", location.x, velocity.x);

		if( f.origin.x < -200 ){
			f.origin.x = -480;
			self.SettingsView.frame = f;
		} else{
			f.origin.x = 0;
			self.SettingsView.frame = f;
		}
		
	} else if (recognizer.state == UIGestureRecognizerStateCancelled){
		NSLog(@"Swipe cancelled at: x=%f, v=%f", location.x, velocity.x);
	}
}
- (IBAction)closePanelGesture:(id)sender {
	NSLog(@"Just closing it, nothing fancy.");
	CGRect f =  self.SettingsView.frame;
	
	// Hide the panel.
	f.origin.x = -480;
	self.SettingsView.frame = f;

}



@end
