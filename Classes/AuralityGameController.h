//
//  AuralityGameController.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioRecorder.h"
#import "FrequencyView.h"
#import "AuralityGameView.h"

#define kAuralityFiringAmplitude 200000
#define kAuralityHighCutoffHz 2500
#define kAuralityMaxAngleFreq 1700
#define kAuralityLowCutoffHz 800

@interface AuralityGameController : UIViewController <AudioRecorderDelegate, UIAccelerometerDelegate> {
	AudioRecorder *recorder;
	IBOutlet UISlider *slider;
	IBOutlet UILabel *label;
	AuralityGameView *gameView;
	
}
@end
