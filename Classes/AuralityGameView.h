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
@end


@interface AuLevel : UIView
{
	NSMutableArray *beams;
	AuPlayer *player;
}
-(id)init;

@property (retain) AuPlayer *player;

@end

@interface AuBeam : UIView
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



@interface AuralityGameView : UIScrollView {
	BOOL firing;
	double angle;
	AuLevel *level;
	CGPoint movementVector;
	
	NSTimer *updateTimer;
	NSTimeInterval lastUpdate;
}
@property (nonatomic) double angle;
@property (nonatomic) BOOL firing;
@property (nonatomic) CGPoint movementVector;

@end
