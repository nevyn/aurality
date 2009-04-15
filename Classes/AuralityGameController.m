//
//  AuralityGameController.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AuralityGameController.h"


@implementation AuralityGameController


-(id)init; {
    if( ! [super initWithNibName:@"AuralityGame" bundle:nil] )
		return nil;
	
	recorder = [[AudioRecorder alloc] init];
	recorder.delegate = self;
	[recorder record];
	
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark 
#pragma mark AudioRecorder delegates
/*-(void)recorder:(AudioRecorder*)recorder_ updatedFrequencies:(complex *)ffts;
{
	[freq newData:ffts count:recorder_.bufferSampleCount/2];
}*/
-(void)recorder:(AudioRecorder*)recorder updatedHighFrequency:(double)frequence amplitude:(double)amp;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	slider.value = amp;
	label.text = [NSString stringWithFormat:@"%f", frequence];
	NSLog(@"Freq: %f Amp: %f", frequence, amp);
	[pool drain];
}

@end
