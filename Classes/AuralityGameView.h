//
//  AuralityGameView.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

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
@property (readonly) AuCannon *cannon;
@end


@interface AuralityGameView : UIView {
	BOOL firing;
	double angle;
	AuPlayer *player;
}
@property (nonatomic) double angle;
@property (nonatomic) BOOL firing;

@end
