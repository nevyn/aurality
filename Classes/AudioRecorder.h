/*
	Adapted from Apple sample code "AudioRecorder". Not an AudioRecorder anymore.

*/


#import <UIKit/UIKit.h>
#import	"AudioQueueObject.h"
#include <complex.h>
#include "fftw3.h"

@class AudioRecorder;
@protocol AudioRecorderDelegate
@optional
//-(void)recorder:(AudioRecorder*)recorder updatedFrequencies:(complex *)ffts;
-(void)recorder:(AudioRecorder*)recorder updatedHighFrequency:(double)frequence amplitude:(double)amp;
@end


@interface AudioRecorder : AudioQueueObject <AudioRecorderDelegate> {
@public
	fftw_plan plan;
	double *fft_in;
	complex *fft_out;
	double frequencyRangeCoveredByOneBuffer;
@protected
	BOOL	stopping;
	int bufferByteSize;
	id<AudioRecorderDelegate> delegate;
}
@property int bufferSampleCount;
@property (readwrite) BOOL	stopping;
@property (assign, nonatomic) id<AudioRecorderDelegate> delegate;

- (void) copyEncoderMagicCookieToFile: (AudioFileID) file fromQueue: (AudioQueueRef) queue;
- (void) setupAudioFormat: (UInt32) formatID;
- (void) setupRecording;

- (void) record;
- (void) stop;

@end
