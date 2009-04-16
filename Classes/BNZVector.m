//
//  BNZVector.m
//  Nevfys
//
//  Created by Joachim Bengtsson on 2006-08-31.
//  Copyright 2006 Joachim Bengtsson. All rights reserved.
//

#import "BNZVector.h"


@implementation BNZVector

-(BNZVector*)initWithSize:(unsigned)asize values:(double)first, ...;
{
	va_list vargs;
	BNZVector* me;
	
	va_start(vargs, first);
	me = [self initWithSize:asize first:first arguments:vargs];
	va_end(vargs);
	
	return me;
}

-(BNZVector*)initWithSize:(unsigned)asize first:(double)first arguments:(va_list)argList;
{
	double *vals = malloc(sizeof(double)*asize);
	unsigned i = 1;
	
	vals[0] = first;
	for(; i < asize; i++)
		vals[i] = va_arg(argList, double);
	
	return [self initWithSize:asize CArray:vals isResponsible:YES];
}

-(BNZVector*)initWithSize:(unsigned)asize CArray:(double*)vals isResponsible:(BNZVectorMemoryResponsibility)isResponsible;
{
	if(![super init]) return nil;
	
	self->size = asize;
	if(isResponsible != BNZVectorMemoryCopy)
		self->values = vals;
	else {
		self->values = malloc(sizeof(double)*asize);
		memcpy(self->values, vals, sizeof(double)*asize);
	}
	
	self->responsibility = isResponsible;
	
	return self;
}

+(BNZVector*)vectorWithSize:(unsigned)asize values:(double)first, ...;
{
	va_list valist;
	va_start(valist, first);
	BNZVector *b = [[BNZVector alloc] initWithSize:asize first:first arguments:valist];
	va_end(valist);
	
	return [b autorelease];
}
+(BNZVector*)vectorWithSize:(unsigned)asize CArray:(double*)vals isResponsible:(BNZVectorMemoryResponsibility)isResponsible;
{
	return [[[BNZVector alloc] initWithSize:asize CArray:vals isResponsible:isResponsible] autorelease];
}
+(BNZVector*)vectorX:(double)x y:(double)y;
{
	double *v = malloc(sizeof(double)*2);
	v[0] = x;
	v[1] = y;
	return [BNZVector vectorWithSize:2 CArray:v isResponsible:BNZVectorMemoryFreeResponsible];
}
+(BNZVector*)vectorFromCGPoint:(CGPoint)point;
{
    return [BNZVector vectorX:point.x y:point.y];
}

-(BNZVector*)copy;
{
	return [[BNZVector alloc] initWithSize:size CArray:values isResponsible:BNZVectorMemoryCopy];
}

-(void)dealloc;
{
    if(responsibility != BNZVectorMemoryResponsibilityNone)
        free(values);
    [super dealloc];
}
-(void)finalize;
{
    if(responsibility != BNZVectorMemoryResponsibilityNone)
        free(values);
    [super finalize];
}

-(double)x; { if(size >= 1) return values[0]; else return nan("");}
-(double)y; { if(size >= 2) return values[1]; else return nan("");}
-(double)z; { if(size >= 3) return values[2]; else return nan("");}
-(double)w; { if(size >= 4) return values[3]; else return nan("");}
-(unsigned)size; { return self->size; }

-(CGPoint)asCGPoint;
{
    return CGPointMake(values[0], values[1]);
}

-(double)angle;
{
    return [self angleFrom:[BNZVector vectorX:1.0 y:0.0]];
}
-(double)angleFrom:(BNZVector*)other;
{
    return - atan2([other y], [other x]) + atan2([self y], [self x]);
}

-(double)length;
{
    double sum = 0.0;
    for(unsigned i = 0; i < size; i++)
        sum += pow(values[i], 2);
    return sqrt(sum);
}
-(double)scalarProductWith:(BNZVector*)other;
{
    if(size != [other size]) return nan("");
    
    double sum = 0.0;
    for(unsigned i = 0; i < size; i++)
        sum += values[i]*other->values[i];
    
    return sum;
}
-(BNZVector*)vectorScaledBy:(double)scalar;
{
	return [[[self copy] autorelease] multiplyWithScalar:scalar];
}
-(BNZVector*)productWithScalar:(double)scalar;
{
	return [[[self copy] autorelease] multiplyWithScalar:scalar];
}
-(BNZVector*)dividendWithScalar:(double)scalar;
{
	return [[[self copy] autorelease] divideByScalar:scalar];
}

-(BNZVector*)sumWithVector:(BNZVector*)other;
{
	return [[[self copy] autorelease] addVector:other];
}
-(BNZVector*)differenceFromVector:(BNZVector*)other;
{
	return [[[self copy] autorelease] subtractVector:other];
}
-(BNZVector*)projectionOn:(BNZVector*)other;
{
	return [[[self copy] autorelease] projectOn:other];
}
-(BNZVector*)inverse;
{
    return [(BNZVector*)[[self copy] autorelease] invert];
}

-(BNZVector*)rightHandNormal;
{
    if(size == 2)
        return [[BNZVector vectorX:[self y] y:-[self x]] normalize];
    
    @throw @"Not implemented for dimensions other than 2";
}
-(BNZVector*)leftHandNormal;
{
    if(size == 2)
        return [[BNZVector vectorX:-[self y] y:[self x]] normalize];
    
    @throw @"Not implemented for dimensions other than 2";
}

-(BNZVector*)normalized;
{
    return [[[self copy] autorelease] normalize];
}



-(BNZVector*)directionVectorTo:(BNZVector*)other;
{
    return [other differenceFromVector:self];
}

-(BNZVector*)multiplyWithScalar:(double)scalar;
{
	for(unsigned i = 0; i < size; i++)
		values[i] *= scalar;
	
	return self;
}
-(BNZVector*)scaleBy:(double)scalar;
{
    return [self multiplyWithScalar:scalar];
}
-(BNZVector*)divideByScalar:(double)scalar;
{
    return [self multiplyWithScalar:1.0/scalar];
}

-(BNZVector*)addVector:(BNZVector*)other;{
	for(unsigned i = 0; i < size; i++)
		values[i] += other->values[i];
	
	return self;
}
-(BNZVector*)subtractVector:(BNZVector*)other;
{
	for(unsigned i = 0; i < size; i++)
		values[i] -= other->values[i];
	
	return self;
}
-(BNZVector*)projectOn:(BNZVector*)other;
{
    return
        [other multiplyWithScalar:
            [other scalarProductWith:self]/
            ([other length]*[other length])
         ];
}

-(BNZVector*)rotateByDegrees:(CGFloat)rotation;
{
    if(size != 2) @throw @"Not implemented";
	return [self rotateByRadians:Deg2Rad(rotation)];
}
-(BNZVector*)rotateByRadians:(CGFloat)rotation;
{
    if(size != 2) @throw @"Not implemented";
	CGAffineTransform af = CGAffineTransformMakeRotation(rotation);
	CGPoint p = CGPointApplyAffineTransform(self.asCGPoint, af);
    values[0] = p.x; values[1] = p.y;
    return self;
}

-(BNZVector*)invert;
{
	for(unsigned i = 0; i < size; i++)
		values[i] = -values[i];
	
	return self;
}

-(BNZVector*)normalize;
{
    double len = [self length];
    for(unsigned i = 0; i < size; i++)
        values[i] /= len;
    return self;
}

-(NSString*)description;
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"( ", size, self];
    for(unsigned i = 0; i < size; i++)
        [desc appendFormat:@"%.2f ", values[i]];
    [desc appendFormat:@")"];
    return desc;
}

@end
