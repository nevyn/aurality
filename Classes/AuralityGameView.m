//
//  AuralityGameView.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AuralityGameView.h"



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
	
	//AuLevel *level = (id)(self.superview.superview); // self<player<level
	
	if(firing) {
		self.layer.contents = (id)[UIImage imageNamed:@"cannon-firing.png"].CGImage;
		//[level createBeamFrom:self];
	} else {
		self.layer.contents = (id)[UIImage imageNamed:@"cannon.png"].CGImage;
		//[level removeBeamFrom:self];
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
	
	beams = [[NSMutableArray alloc] init];
	walls = [[NSMutableArray alloc] init];
	
	[self addWall:Line4f(0, 0, self.frame.size.width, 0) type:[AuWall class]];
	[self addWall:Line4f(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) type:[AuWall class]];
	[self addWall:Line4f(self.frame.size.width, self.frame.size.height, 0, self.frame.size.height) type:[AuWall class]];
	[self addWall:Line4f(0, self.frame.size.height, 0, 0) type:[AuWall class]];
	
	player = [[AuPlayer alloc] init];
	[self addSubview:player];
	player.layer.position = CGPointMake(128, 128);
	
	return self;
}
-(void)dealloc;
{
	[player release];
	[beams release];
	[walls release];
	[super dealloc];
}

-(void)addWall:(BNZLine*)line type:(Class)class;
{
	AuWall *wall = [[class alloc] initWithLine:line];
	[walls addObject:wall];
	[self addSubview:wall];
	[wall release];
}

@synthesize player;


-(void)updateBeams;
{
	for (LineView *beam in [[beams copy] autorelease]) {
		[beam removeFromSuperview];
		[beams removeObject:beam];
	}
	
	if( ! player.cannon.firing ) return;
	
	BNZVector *dir = VecXY(0, -1);
	[dir rotateByDegrees:player.cannon.angle];
	
	BNZVector *pl = VecCG(player.layer.position);
	
	BNZVector *start = [pl sumWithVector:[dir vectorScaledBy:32]];
	
	BNZVector *end = [start sumWithVector:[dir vectorScaledBy:300]];
	
	LineView *beam = [[LineView alloc] initStart:start.asCGPoint end:end.asCGPoint];
	
	[beams addObject:beam];
	[self addSubview:beam];
	[beam release];
	
}

@end


static double beamWidth = 5;

@implementation LineView
-initStart:(CGPoint)start_ end:(CGPoint)end_;
{
    if(![super initWithFrame:CGRectZero]) return nil;
    self.layer.anchorPoint = CGPointMake(0, 0.5);
        
    self.start = start_;
    self.end = end_;
    return self;
}
-initWithLine:(BNZLine*)line;
{
    return [self initStart:[[line start] asCGPoint] end:[[line end] asCGPoint]];
}
-init;
{
    return [self initStart:CGPointMake(0, 0) end:CGPointMake(0,0)];
}

@synthesize start;
@synthesize end;
-(void)setStart:(CGPoint)start_;
{
    start = start_;
    end = start_;
}

-(void)setEnd:(CGPoint)end_;
{
    end = end_;
    [self reshape];
}
-(BNZLine*)line;
{
    return [BNZLine lineAt:VecCG(self.start) to:VecCG(self.end)];
}


-(void)reshape;
{
    float length = self.line.vector.length;
    
    self.layer.affineTransform = CGAffineTransformMakeRotation(self.line.vector.angle);
    self.frame = CGRectMake(start.x, start.y, length, beamWidth);
    CGRect r = self.frame; r.origin.x = r.origin.y = 0; r.size.height = beamWidth;
    self.bounds = r;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColor(context, (CGFloat[4]){0,0,0,0});
	UIRectFill(rect);
	
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, .0f, beamWidth/4.);
    CGContextAddLineToPoint(context, self.bounds.size.width, .0f);
    
    CGContextSetLineWidth(context, beamWidth/2.);
    CGContextSetStrokeColor(context, (CGFloat[4]){1,0,0,1});
    CGContextStrokePath(context);
    
}

@end
@implementation AuBeam
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColor(context, (CGFloat[4]){0,0,0,0});
	UIRectFill(rect);
	
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, .0f, beamWidth/4.);
    CGContextAddLineToPoint(context, self.bounds.size.width, .0f);
    
    CGContextSetLineWidth(context, beamWidth/2.);
    CGContextSetStrokeColor(context, (CGFloat[4]){1,0,0,1});
    CGContextStrokePath(context);
    
}
@end

@implementation AuWall
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColor(context, (CGFloat[4]){0,0,0,0});
	UIRectFill(rect);
	
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, .0f, beamWidth/4.);
    CGContextAddLineToPoint(context, self.bounds.size.width, .0f);
    
    CGContextSetLineWidth(context, beamWidth/2.);
    CGContextSetStrokeColor(context, (CGFloat[4]){0,1,0,1});
    CGContextStrokePath(context);
    
}
-(BOOL)reflects; { return NO; }
@end

@implementation AuMirror
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColor(context, (CGFloat[4]){0,0,0,0});
	UIRectFill(rect);
	
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, .0f, beamWidth/4.);
    CGContextAddLineToPoint(context, self.bounds.size.width, .0f);
    
    CGContextSetLineWidth(context, beamWidth/2.);
    CGContextSetStrokeColor(context, (CGFloat[4]){0.4,0.4,1,1});
    CGContextStrokePath(context);
}
-(BOOL)reflects; { return YES; }
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
	
	lastUpdate = [NSDate timeIntervalSinceReferenceDate];
	self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1./40. target:self selector:@selector(update) userInfo:nil repeats:YES];
		
    return self;
}


- (void)dealloc {
	self.updateTimer = nil;
	[level release];
    [super dealloc];
}

-(void)update;
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval d = now - lastUpdate;
	
	CGPoint newPos = CGPointMake(level.player.layer.position.x + movementVector.x*d, level.player.layer.position.y + movementVector.y*d);
	
	BOOL isInLevel = newPos.x > 16 && newPos.y > 16 && newPos.x < level.frame.size.width-16 && newPos.y < level.frame.size.height-16;
	
	if(isInLevel)
		level.player.layer.position = newPos;
	
	self.contentOffset = CGPointMake(level.player.layer.position.x-self.frame.size.width/2, level.player.layer.position.y-self.frame.size.height/2);
	
	lastUpdate = now;
	
	[level updateBeams];
}

-(double)angle; { return level.player.cannon.angle; }
-(void)setAngle:(double)newAngle;
{
	level.player.cannon.angle = newAngle;
}
-(BOOL)firing;
{
	return level.player.cannon.firing;
}
-(void)setFiring:(BOOL)newFire;
{
	level.player.cannon.firing = newFire;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *t = [[event allTouches] anyObject];
	CGPoint p = [t locationInView:self.superview];

	if(p.y < 100)
		self.movementVector = CGPointMake(0, -200);
	else if(p.y > 350)
		self.movementVector = CGPointMake(0, 200);
	else if(p.x < 75)
		self.movementVector = CGPointMake(-200, 0);
	else if(p.x > 165)
		self.movementVector = CGPointMake(200, 0);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.movementVector = CGPointMake(0, 0);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event; {}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event; {}


@end
