//
//  AuralityGameController.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AuralityGameController.h"
@interface AuralityGameController ()
@property (nonatomic, retain) AuralityGameView *gameView;
@end

#define kAccelerometerFrequency     40


@implementation AuralityGameController


-(id)init; {
    if( ! [super initWithNibName:@"AuralityGame" bundle:nil] )
		return nil;
	
	recorder = [[AudioRecorder alloc] init];
	recorder.delegate = self;
	[recorder record];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];

	
    return self;
}

- (void)dealloc {
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	CGRect r = self.view.frame; r.origin = CGPointMake(0, 0);
	self.gameView = [[[AuralityGameView alloc] initWithFrame:r] autorelease];
	[self.view addSubview:self.gameView];
	// TODO: didReceiveMemoryWarning will probably make all this crash
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@synthesize gameView;

// In degrees
-(double)angleFromFrequency:(double)freq_;
{
	double frac = (freq_-kAuralityLowCutoffHz)/(kAuralityMaxAngleFreq-kAuralityLowCutoffHz);
	return frac*360.;
}


#pragma mark 
#pragma mark AudioRecorder delegates

-(void)recorder:(AudioRecorder*)recorder updatedHighFrequency:(double)frequence amplitude:(double)amp;
{
	BOOL isInRange = frequence > kAuralityLowCutoffHz && frequence < kAuralityHighCutoffHz;
	
	if(amp > kAuralityFiringAmplitude && isInRange)
		self.gameView.firing = YES;
	else {
		self.gameView.firing = NO;
		return;
	}
	
	self.gameView.angle = [self angleFromFrequency:frequence];
}

#pragma mark Gyro delegates
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acc
{
	CGPoint newP = CGPointMake(acc.x, -(acc.y+0.6));
	newP.x *= 400.;
	newP.y *= 600.;
	self.gameView.movementVector = newP;
}
@end
