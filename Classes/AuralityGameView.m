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
-(CGRect)boundingFrame;
{
	CGRect r = self.frame;
	r.size = CGSizeMake(50, 50);
	return r;
}
- (void)dealloc {
	self.cannon = nil;
    [super dealloc];
}
@synthesize cannon;
@end






@implementation AuLevel

-(id)initWithName:(NSString*)levelName;
{
	if( ! [super initWithFrame:CGRectMake(0, 0, 480, 640)] ) return nil;
	
	beams = [[NSMutableArray alloc] init];
	walls = [[NSMutableArray alloc] init];
	switches = [[NSMutableArray alloc] init];
	
	player = [[AuPlayer alloc] init];
	[self addSubview:player];
	player.layer.position = CGPointMake(128, 128);
	
	
	[self loadLevel:levelName];
	
	
	return self;
}
-(void)dealloc;
{
	[player release];
	[beams release];
	[walls release];
	[switches release];
	[super dealloc];
}

-(AuWall*)addWall:(BNZLine*)line type:(Class)class;
{
	AuWall *wall = [[class alloc] initWithLine:line];
	[walls addObject:wall];
	[self addSubview:wall];
	[wall release];
	return wall;
}

-(void)loadLevel:(NSString*)name;
{
	for (AuWall *wall in [[walls copy] autorelease]) {
		[wall removeFromSuperview];
		[walls removeObject:wall];
	}
	for (AuSwitch *sw in self.switches) {
		[sw removeFromSuperview];
		[switches removeObject:sw];
	}
	
	NSDictionary *rep = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"plist"]];
	
	self.layer.contents = (id)[UIImage imageNamed:[rep objectForKey:@"background"]].CGImage;
	
	CGRect frame = CGRectMake(0, 0, [[rep objectForKey:@"width"] floatValue], [[rep objectForKey:@"height"] floatValue]);
	self.frame = frame;
	
	player.layer.position = CGPointMake([[rep objectForKey:@"startx"] floatValue], [[rep objectForKey:@"starty"] floatValue]);
	
	[self addWall:Line4f(0, 0, self.frame.size.width, 0) type:[AuWall class]];
	[self addWall:Line4f(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) type:[AuWall class]];
	[self addWall:Line4f(self.frame.size.width, self.frame.size.height, 0, self.frame.size.height) type:[AuWall class]];
	[self addWall:Line4f(0, self.frame.size.height, 0, 0) type:[AuWall class]];
	
	for (NSDictionary *wd in [rep objectForKey:@"walls"]) {
		BNZLine *l = Line4f([[wd objectForKey:@"x1"] floatValue], [[wd objectForKey:@"y1"] floatValue], [[wd objectForKey:@"x2"] floatValue], [[wd objectForKey:@"y2"] floatValue]);
		AuWall *wall = [self addWall:l type:NSClassFromString([wd objectForKey:@"class"])];
		if([[wd objectForKey:@"class"] isEqual:@"AuExit"])
			exit = (id)wall;
	}
	
	for (NSDictionary *sd in [rep objectForKey:@"switches"]) {
		CGPoint p = CGPointMake([[sd objectForKey:@"x"] floatValue], [[sd objectForKey:@"y"] floatValue]);
		AuSwitch *sw = [[AuSwitch alloc] init];
		sw.layer.position = p;
		sw.delay = [[sd objectForKey:@"delay"] floatValue];
		[switches addObject:sw];
		[self addSubview:sw];
		[sw release];
	}
	
	
}

@synthesize player;
@synthesize exit;

-(void)beamFrom:(BNZVector*)start direction:(BNZVector*)dir ignoringWall:(AuWall*)ignore;
{
	BNZVector *end = [start sumWithVector:[dir vectorScaledBy:400]];
	
	BNZLine *beamLine = [BNZLine lineAt:start to:end];
	
	for (AuWall *wall in walls) {
		// Stop/reflection
		if(wall == ignore || wall.transparent) continue;
		
		BNZVector *intersectionPoint = [beamLine intersectionPointWithLine:wall.line];
		if(!intersectionPoint) continue;
		end = intersectionPoint;
		beamLine = [BNZLine lineAt:start to:end]; // because end changed
		
		if(wall.reflects) {
			BNZVector *wallNormalL = [wall.line.vector leftHandNormal];
			BNZVector *wallNormalR = [wall.line.vector rightHandNormal];
			float lenL = [[dir sumWithVector:wallNormalL] length];
			float lenR = [[dir sumWithVector:wallNormalR] length];
			// choose the one pointing toward the incoming beam
			BNZVector *wallNormal = (lenL < lenR) ? wallNormalL : wallNormalR;
			
			BNZVector *newDir = [dir sumWithVector:[wallNormal productWithScalar:2.0]];
			
			[self beamFrom:end direction:newDir ignoringWall:wall];
		} 
	}
	
	
	LineView *beam = [[LineView alloc] initWithLine:beamLine];
	
	for ( AuSwitch *sw in switches ) {
		if([beamLine intersectsRect:sw.frame]) {
			sw.activated = YES;
		}
	}
	
	[beams addObject:beam];
	[self addSubview:beam];
	[beam release];
	
}

-(void)updateBeams;
{
	for (id beam in [[beams copy] autorelease]) {
		[beam removeFromSuperview];
		[beams removeObject:beam];
	}
	
	if( ! player.cannon.firing ) return;
	
	BNZVector *dir = VecXY(0, -1);
	[dir rotateByDegrees:player.cannon.angle];
	
	BNZVector *pl = VecCG(player.layer.position);
	BNZVector *start = [pl sumWithVector:[dir vectorScaledBy:32]];
	
	[self beamFrom:start direction:dir ignoringWall:nil];	
}

-(NSArray*)walls;
{
	return [[walls copy] autorelease];
}
-(NSArray*)switches;
{
	return [[switches copy] autorelease];
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

-(NSString*)description;
{
	return self.line.description;
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
-(BOOL)transparent; { return NO; }
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
-(BOOL)transparent; { return NO; }
@end

@implementation AuWindow
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColor(context, (CGFloat[4]){0,0,0,0});
	UIRectFill(rect);
	
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, .0f, .0f);
    CGContextAddLineToPoint(context, self.bounds.size.width, .0f);
    
    CGContextSetLineWidth(context, beamWidth*3);
    CGContextSetStrokeColor(context, (CGFloat[4]){0.6,0.6,1,1});
    CGContextStrokePath(context);
}
-(BOOL)reflects; { return NO; }
-(BOOL)transparent; { return YES; }
@end

@implementation AuExit
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColor(context, (CGFloat[4]){0,0,0,0});
	UIRectFill(rect);
	
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, .0f, .0f);
    CGContextAddLineToPoint(context, self.bounds.size.width, .0f);
    
    CGContextSetLineWidth(context, beamWidth*3);
	if( ! open)
		CGContextSetStrokeColor(context, (CGFloat[4]){1,0,0,1});
	else
		CGContextSetStrokeColor(context, (CGFloat[4]){0,1,0,1});
	
    CGContextStrokePath(context);
}
@synthesize open;
-(void)setOpen:(BOOL)newOpen;
{
	open = newOpen;
	[self setNeedsDisplay];
}
@end

@interface AuSwitch ()
@property (retain, nonatomic) NSTimer *deactivationTimer;
@property (retain, nonatomic) UILabel *countdownLabel;
@end

@implementation AuSwitch
-(id)init;
{
	if( ! [super initWithFrame:CGRectMake(0, 0, 32, 32)] ) return nil;
	
	activated = 2; // hack: make sure setActivated triggers change
	self.activated = NO;

	return self;
}
-(void)dealloc;
{
	self.deactivationTimer = nil;
	self.countdownLabel = nil;
	[super dealloc];
}
@synthesize activated;
-(void)setActivated:(BOOL)newActivated;
{
	activated = newActivated;
	
	self.deactivationTimer = nil;
	
	activatedAt = [NSDate timeIntervalSinceReferenceDate];
	
	if(activated) {
		self.layer.contents = (id)[UIImage imageNamed:@"switch-activated.png"].CGImage;
		self.deactivationTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:NO];
	} else {
		self.layer.contents = (id)[UIImage imageNamed:@"switch.png"].CGImage;
	}
}

-(void)timerCountdown; {
	if( ! self.countdownLabel ) {
		self.countdownLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 32, 32)] autorelease];
		self.countdownLabel.opaque = NO;
		self.countdownLabel.backgroundColor = [UIColor clearColor];
	}
	
	NSTimeInterval secondsElapsed = [NSDate timeIntervalSinceReferenceDate] - activatedAt;
	NSTimeInterval secondsRemaining = delay - secondsElapsed;
	
	self.countdownLabel.text = [NSString stringWithFormat:@"%d", (int)secondsRemaining];
	
	if(secondsRemaining < 1) {
		self.activated = NO;
		self.countdownLabel = nil;
	} else {
		self.deactivationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCountdown) userInfo:nil repeats:NO];
	}
}

@synthesize deactivationTimer;
-(void)setDeactivationTimer:(NSTimer*)t;
{
	if(t == deactivationTimer) return;
	[t retain];
	[deactivationTimer invalidate];
	[deactivationTimer release];
	deactivationTimer = t;
}
@synthesize delay;
@synthesize countdownLabel;
-(void)setCountdownLabel:(UILabel*)label;
{
	if(!label)
		[countdownLabel removeFromSuperview];
	[label retain];
	[countdownLabel release];
	countdownLabel = label;
	if(label)
		[self addSubview:label];
}
@end




@interface AuralityGameView ()
@property (retain) NSTimer *updateTimer;
@end


@implementation AuralityGameView
- (id)initWithFrame:(CGRect)frame {
    if ( ! [super initWithFrame:frame] ) return nil;
	
	level = [[AuLevel alloc] initWithName:@"level1"];
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
	
	CGPoint oldPos = level.player.layer.position;
	
	BNZVector *pl = VecCG(level.player.layer.position);
	BNZVector *move = VecCG(movementVector);
	[move multiplyWithScalar:d];
	
	BNZVector *newPos = [pl addVector:move];
	
	level.player.layer.position = newPos.asCGPoint;
	
	BOOL collidingWithWall = NO;
	
	for (AuWall *wall in level.walls) {
		collidingWithWall = [wall.line intersectsRect:level.player.boundingFrame];
		if(collidingWithWall) {
			level.player.layer.position = oldPos;
			break;
		}
	}
	
	BOOL allActivated = YES;
	for (AuSwitch *sw in level.switches) {
		allActivated &= sw.activated;
	}
	level.exit.open = allActivated;
		
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
