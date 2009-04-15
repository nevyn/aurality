//
//  FrequencyView.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <complex.h>

@interface FrequencyView : UIView {
	int numCount;
	complex *fft;
}
-(void)newData:(complex*)fft_ count:(int)count_;
@end
