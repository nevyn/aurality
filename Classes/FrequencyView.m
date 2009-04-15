//
//  FrequencyView.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "FrequencyView.h"


@implementation FrequencyView


- (id)initWithFrame:(CGRect)frame {
    if ( ! [super initWithFrame:frame]) return nil;
	
	fft = NULL;
	numCount = 0;
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	if( ! numCount ) return;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColor(ctx, (CGFloat[4]){1.0, 1.0, 1.0, 1.0});
	UIRectFill(rect);
	
	
	double max = 400000;
	double eachW = self.frame.size.width/numCount;
	
	double mmmax = -1;
	
	for(int i = 0; i < numCount; i++) {
		double mag = sqrt(creal(fft[i])*creal(fft[i]) + cimag(fft[i])*cimag(fft[i]));
		
		//NSLog(@"i %d mag %f", i, mag);
		
		if(mag > mmmax) mmmax = mag;

		double height = (mag/max)*self.frame.size.height;
		CGRect r = CGRectMake(i*eachW, self.frame.size.height-height, 1, height);
		
		//NSLog(@"rect %@", NSStringFromRect(NSRectFromCGRect(r)));
		
		CGContextSetFillColor(ctx, (CGFloat[4]){1.0, 0.0, 0.0, 1.0});
		UIRectFill(r);
		
	}
	
}



-(void)newData:(complex*)fft_ count:(int)count_;
{
	fft = fft_;
	numCount = count_/5;
	[self setNeedsDisplay];
}

@end
