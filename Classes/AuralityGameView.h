//
//  AuralityGameView.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BNZLine.h"
#import <AVFoundation/AVFoundation.h>

@interface AuCannon : UIView
{
	BOOL firing;
	double angle;
}
@property (nonatomic) BOOL firing;
@property (nonatomic) double angle;
-(id)init;
@end
@interface AuPlayer : UIView
{
	AuCannon *cannon;
}
-(id)init;
@property (retain) AuCannon *cannon;
-(CGRect)boundingFrame;
@end

@class AuExit;
@class AuWall;
@interface AuLevel : UIView
{
	NSMutableArray *beams;
	AuPlayer *player;
	NSMutableArray *walls;
	NSMutableArray *switches;
	AuExit *exit;
}
-(id)init;
-(AuWall*)addWall:(BNZLine*)line type:(Class)class;
-(void)loadLevel:(NSString*)name;

@property (retain) AuPlayer *player;
@property (readonly) NSArray *walls;
@property (readonly) NSArray *switches;
@property (readonly) AuExit *exit;
@end

@interface LineView : UIView
{
	CGPoint start, end;
}

-initStart:(CGPoint)start end:(CGPoint)end;
-initWithLine:(BNZLine*)line;
-(void)reshape;

@property(assign) CGPoint start;
@property(assign) CGPoint end;
-(BNZLine*)line;
@end

@interface AuBeam : LineView
@end

@interface AuWall : LineView
-(BOOL)reflects;
-(BOOL)transparent;
@end

@interface AuMirror : AuWall
-(BOOL)reflects;
-(BOOL)transparent;
@end

@interface AuWindow : AuWall
-(BOOL)reflects;
-(BOOL)transparent;
@end

@interface AuSwitch : UIView
{
	BOOL activated;
	NSTimeInterval delay;
	NSTimeInterval activatedAt;
	NSTimer *deactivationTimer;
	UILabel *countdownLabel;
}
-(id)init;
@property BOOL activated;
@property NSTimeInterval delay;

@end


@interface AuExit : AuWall { BOOL open; }
@property BOOL open;
@end

@interface AuralityGameView : UIScrollView <AVAudioPlayerDelegate> {
	BOOL firing;
	double angle;
	AuLevel *level;
	CGPoint movementVector;
	
	UILabel *plaque;
	
	int levelNo;
	
	NSTimer *updateTimer;
	NSTimeInterval lastUpdate;
}
@property (nonatomic) double angle;
@property (nonatomic) BOOL firing;
@property (nonatomic) CGPoint movementVector;
-(void)clearLevel;
@end
