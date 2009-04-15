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

@interface AuralityGameController : UIViewController <AudioRecorderDelegate> {
	AudioRecorder *recorder;
	IBOutlet FrequencyView *freq;
}

@end
