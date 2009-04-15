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
- (void)dealloc {
	self.cannon = nil;
    [super dealloc];
}
@synthesize cannon;
@end


@implementation AuLevel

-(id)init;
{
	if( ! [super initWithFrame:CGRectMake(0, 0, 480, 640)] ) return nil;
	
	self.layer.contents = (id)[UIImage imageNamed:@"level1.png"].CGImage;
	
	
	return self;
}


@end






@interface AuralityGameView ()
@property (retain) NSTimer *updateTimer;
@end


@implementation AuralityGameView
- (id)initWithFrame:(CGRect)frame {
    if ( ! [super initWithFrame:frame] ) return nil;
	
	level = [[AuLevel alloc] init];
	[self addSubview:level];
	self.contentSize = level.frame.size;
	
	player = [[AuPlayer alloc] init];
	[level addSubview:player];
	player.layer.position = CGPointMake(128, 128);
	
	lastUpdate = [NSDate timeIntervalSinceReferenceDate];
	self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1./40. target:self selector:@selector(update) userInfo:nil repeats:YES];
		
    return self;
}


- (void)dealloc {
	self.updateTimer = nil;
	[level release];
	[player release];
    [super dealloc];
}

-(void)update;
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval d = now - lastUpdate;
	
	player.layer.position = CGPointMake(player.layer.position.x + movementVector.x*d, player.layer.position.y + movementVector.y*d);
	
	self.contentOffset = CGPointMake(player.layer.position.x-self.frame.size.width/2, player.layer.position.y-self.frame.size.height/2);
//	[self scrollRectToVisible:CGRectMake(player.layer.position.x, player.layer.position.y, 32, 32) animated:YES];
	
	lastUpdate = now;
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
@synthesize movementVector;
-(void)setMovementVector:(CGPoint)newV;
{
	if(newV.x == movementVector.x && newV.y == movementVector.y) return;
	
	movementVector = newV;
}

@synthesize updateTimer;
-(void)setUpdateTimer:(NSTimer*)t;
{
	if(t == updateTimer) return;
	[t retain];
	[updateTimer invalidate];
	[updateTimer release];
	updateTimer = t;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return NO;
}


@end
