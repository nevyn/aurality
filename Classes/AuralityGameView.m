//
//  AuralityGameView.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AuralityGameView.h"

#define Deg2Rad(Deg) ((Deg * M_PI) / 180.0)
#define Rad2Deg(Rad) ((180.0 * Rad) / M_PI)


@implementation AuCannon
-(id)init;
{
	if( ! [super initWithFrame:CGRectMake(0, 0, 64, 64)] ) return nil;
	self.firing = YES;
	self.firing = NO;
	self.layer.anchorPoint = CGPointMake(0.5, 0.5);
	return self;
}
@synthesize angle;
-(void)setAngle:(double)newAngle;
{
	angle = newAngle;
	self.layer.affineTransform = CGAffineTransformMakeRotation(Deg2Rad(newAngle));
}
@synthesize firing;
-(void)setFiring:(BOOL)fire;
{
	if(fire == firing) return;
	firing = fire;
	if(firing) {
		self.layer.contents = (id)[UIImage imageNamed:@"cannon-firing.png"].CGImage;
	} else {
		self.layer.contents = (id)[UIImage imageNamed:@"cannon.png"].CGImage;
	}
}
@end


@implementation AuPlayer
-(id)init;
{
	if( ! [super initWithFrame:CGRectMake(0, 0, 64, 64)] ) return nil;
	
	self.layer.contents = (id)[UIImage imageNamed:@"player.png"].CGImage;
	
	cannon = [[AuCannon alloc] init];
	[self addSubview:cannon];
	
	return self;
}
@synthesize cannon;
@end


@implementation AuralityGameView
- (id)initWithFrame:(CGRect)frame {
    if ( ! [super initWithFrame:frame] ) return nil;
	
	player = [[AuPlayer alloc] init];
	[self addSubview:player];
	player.layer.position = CGPointMake(128, 128);
		
    return self;
}


- (void)dealloc {
    [super dealloc];
}

-(double)angle; { return player.cannon.angle; }
-(void)setAngle:(double)newAngle;
{
	player.cannon.angle = newAngle;
}
-(BOOL)firing;
{
	return player.cannon.firing;
}
-(void)setFiring:(BOOL)newFire;
{
	player.cannon.firing = newFire;
}

@end
