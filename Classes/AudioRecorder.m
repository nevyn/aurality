#import <AudioToolbox/AudioToolbox.h>
#import "AudioQueueObject.h"
#import "AudioRecorder.h"

// Audio queue recording callback, which performs recording using Audio File Services.
static void recordingCallback (
	void								*inUserData,
	AudioQueueRef						inAudioQueue,
	AudioQueueBufferRef					inBuffer,
	const AudioTimeStamp				*inStartTime,
	UInt32								inNumPackets,
	const AudioStreamPacketDescription	*inPacketDesc
) {
	// This callback, being outside the implementation block, needs a reference to the 
	//	AudioRecorder object -- which it gets via the inUserData parameter.
	AudioRecorder *rec = (AudioRecorder *) inUserData;
	signed short *samples = inBuffer->mAudioData;
	
	NSLog(@"Got data %d packets", inNumPackets);
		
	// if there is audio data, write it to the file
	if (inNumPackets > 0) {
		
		for(int i = 0; i < inNumPackets; i++) {
			rec->fft_in[i] = samples[i];
		}
		
		fftw_execute(rec->plan); /* repeat as needed */
		[rec.delegate recorder:rec updatedFrequencies:rec->fft_out];
	}

	// if not stopping, re-enqueue the buffer so that it can be filled again
	if (rec.isRunning) {

		AudioQueueEnqueueBuffer (
			inAudioQueue,
			inBuffer,
			0,
			NULL
		);
	}
}

// Audio queue poperty callback function, called when an audio queue property changes. The  
//	only Audio Queue Services property as of Mac OS X v10.5.3 is 
//	kAudioQueueProperty_IsRunning.
static void audioQueuePropertyListenerCallback (
	void					*inUserData,
	AudioQueueRef			queueObject,
	AudioQueuePropertyID	propertyID
) {
	AudioRecorder *recorder = (AudioRecorder *) inUserData;

	if (recorder.stopping) {
	
		// A codec may update its cookie at the end of an encoding session, so reapply it to the file now.
		// Linear PCM, as used in this app, doesn't have magic cookies. This is included in case you
		// want to change to a format that does use magic cookies.
		[recorder copyEncoderMagicCookieToFile: recorder.audioFileID fromQueue: recorder.queueObject];

		AudioFileClose (recorder.audioFileID);
	}

}


@implementation AudioRecorder

@synthesize stopping;

-init;
{
	return [(id)self initWithURL:nil];
}

- (id) initWithURL: fileURL {
	NSLog (@"initializing a recorder object.");
	if( ! [super init] ) return nil;


	[self setupAudioFormat: kAudioFormatLinearPCM];

	OSStatus result =	AudioQueueNewInput (
							&audioFormat,
							recordingCallback,
							self,					// userData
							NULL,					// run loop
							NULL,					// run loop mode
							0,						// flags
							&queueObject
						);

	NSLog (@"Attempted to create new recording audio queue object. Result: %f", result);

	// get the recording format back from the audio queue's audio converter --
	//	the file may require a more specific stream description than was 
	//	necessary to create the encoder.
	UInt32 sizeOfRecordingFormatASBDStruct = sizeof (audioFormat);
	
	AudioQueueGetProperty (
		queueObject,
		kAudioQueueProperty_StreamDescription,	// this constant is only available in iPhone OS
		&audioFormat,
		&sizeOfRecordingFormatASBDStruct
	);
	
	AudioQueueAddPropertyListener (
		[self queueObject],
		kAudioQueueProperty_IsRunning,
		audioQueuePropertyListenerCallback,
		self
	);
	
	self.bufferSampleCount = 2048;
	
	// setup fftw
	fft_in = fftw_malloc(sizeof(double) * self.bufferSampleCount);
	fft_out = fftw_malloc(sizeof(fftw_complex) * (self.bufferSampleCount/2 + 1));
	plan = fftw_plan_dft_r2c_1d(self.bufferSampleCount, fft_in, fft_out, FFTW_ESTIMATE);
	
	
	return self;
} 

- (void) dealloc {
	
	AudioQueueDispose (
					   queueObject,
					   TRUE
					   );
	
	fftw_destroy_plan(plan);
	fftw_free(fft_in); fftw_free(fft_out);
	
	
	[super dealloc];
}

-(int)bufferSampleCount;
{
	return bufferByteSize/2;
}
-(void)setBufferSampleCount:(int)newCount;
{
	bufferByteSize = newCount*2;
}


- (void) copyEncoderMagicCookieToFile: (AudioFileID) theFile fromQueue: (AudioQueueRef) theQueue {
}


- (void) record {

	[self setupRecording];

	AudioQueueStart (
		queueObject,
		NULL			// start time. NULL means as soon as possible.
	);
}


- (void) stop {

	AudioQueueStop (
		queueObject,
		TRUE			// stop immediately.
	);
}

// Configures the audio data format for recording
- (void) setupAudioFormat: (UInt32) formatID {

	// Obtains the hardware sample rate for use in the recording
	// audio format. Each time the audio route changes, the sample rate
	// needs to get updated.
	UInt32 propertySize = sizeof (self.hardwareSampleRate);
	
	AudioSessionGetProperty (
		kAudioSessionProperty_CurrentHardwareSampleRate,
		&propertySize,
		&hardwareSampleRate
	);
	
// When running in the Simulator, the kAudioSessionProperty_CurrentHardwareSampleRate
//	property is not available, so set it manually.
#if TARGET_IPHONE_SIMULATOR
		audioFormat.mSampleRate = 44100.0;
#else
		audioFormat.mSampleRate = self.hardwareSampleRate;
#endif

	NSLog (@"Hardware sample rate = %f", self.audioFormat.mSampleRate);

	audioFormat.mFormatID			= formatID;
	audioFormat.mChannelsPerFrame	= 1;
	
	if (formatID == kAudioFormatLinearPCM) {
	
		audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
		audioFormat.mFramesPerPacket	= 1;
		audioFormat.mBitsPerChannel		= 16;
		audioFormat.mBytesPerPacket		= 2;
		audioFormat.mBytesPerFrame		= 2;
	}
}


- (void) setupRecording {

	self.startingPacketNumber = 0;

	// allocate and enqueue buffers
	int bufferIndex;
	
	for (bufferIndex = 0; bufferIndex < kNumberAudioDataBuffers; ++bufferIndex) {
	
		AudioQueueBufferRef buffer;
		
		AudioQueueAllocateBuffer (
			queueObject,
			bufferByteSize, &buffer
		);

		AudioQueueEnqueueBuffer (
			queueObject,
			buffer,
			0,
			NULL
		);
	}
}




@synthesize delegate;
@end
