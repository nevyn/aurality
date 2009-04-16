//
//  BNZVector.h
//  Nevfys
//
//  Created by Joachim Bengtsson on 2006-08-31.
//  Copyright 2006 Joachim Bengtsson. All rights reserved.
//

typedef enum {
	BNZVectorMemoryResponsibilityNone,
	BNZVectorMemoryFreeResponsible,
	BNZVectorMemoryCopy
} BNZVectorMemoryResponsibility;

#define VecCG(cgpoint) [BNZVector vectorFromCGPoint:cgpoint]
#define VecXY(x_, y_) [BNZVector vectorX:x_ y:y_]


@interface BNZVector : NSObject {
	double *values;
	unsigned size;
	BNZVectorMemoryResponsibility responsibility;
}

// Constructors

-(BNZVector*)initWithSize:(unsigned)size values:(double)first, ...;

-(BNZVector*)initWithSize:(unsigned)size first:(double)first arguments:(va_list)argList;

-(BNZVector*)initWithSize:(unsigned)size CArray:(double*)values isResponsible:(BNZVectorMemoryResponsibility)isResponsible;

+(BNZVector*)vectorWithSize:(unsigned)size values:(double)first, ...;

+(BNZVector*)vectorWithSize:(unsigned)size CArray:(double*)values isResponsible:(BNZVectorMemoryResponsibility)isResponsible;

+(BNZVector*)vectorX:(double)x y:(double)y;
+(BNZVector*)vectorFromCGPoint:(CGPoint)point;

-(BNZVector*)copy;

// Accesors
-(double)x;
-(double)y;
-(double)z;
-(double)w;
-(unsigned)size;

-(CGPoint)asCGPoint;

// Anti-clockwise, in radians, 0° being vector pointing to the right.
-(double)angle;
-(double)angleFrom:(BNZVector*)other;

-(double)length;
-(double)scalarProductWith:(BNZVector*)other;

-(BNZVector*)vectorScaledBy:(double)scalar;
-(BNZVector*)productWithScalar:(double)scalar;
-(BNZVector*)dividendWithScalar:(double)scalar;

-(BNZVector*)sumWithVector:(BNZVector*)other;
-(BNZVector*)differenceFromVector:(BNZVector*)other;
-(BNZVector*)projectionOn:(BNZVector*)other;

-(BNZVector*)inverse;

-(BNZVector*)rightHandNormal;
-(BNZVector*)leftHandNormal;

-(BNZVector*)normalized;

-(BNZVector*)directionVectorTo:(BNZVector*)other;

// Mutators
-(BNZVector*)multiplyWithScalar:(double)scalar;
-(BNZVector*)scaleBy:(double)scalar;
-(BNZVector*)divideByScalar:(double)scalar;

-(BNZVector*)addVector:(BNZVector*)other;
-(BNZVector*)subtractVector:(BNZVector*)other;
-(BNZVector*)projectOn:(BNZVector*)other;

    // 2D rotations
-(BNZVector*)rotateByDegrees:(CGFloat)rotation;
-(BNZVector*)rotateByRadians:(CGFloat)rotation;

-(BNZVector*)invert;

-(BNZVector*)normalize;

-(NSString*)description;
@end
