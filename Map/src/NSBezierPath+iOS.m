//
//  NSBezierPath+iOS.m
//  CalloutViewSample OS X
//
//  Created by David Bainbridge on 5/9/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "NSBezierPath+iOS.h"

@implementation NSBezierPath (iOS)
- (void)addLineToPoint:(NSPoint)aPoint
{
    [self lineToPoint:aPoint];
}

- (void)addArcWithCenter:(NSPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise
{
    [self appendBezierPathWithArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
}

- (void)appendPath:(NSBezierPath *)aPath
{
    [self appendBezierPath:aPath];

}

- (void)applyTransform:(CGAffineTransform)aTransform
{
/*
 struct CGAffineTransform {
        CGFloat a;
        CGFloat b;
        CGFloat c;
        CGFloat d;
        CGFloat tx;
        CGFloat ty;
    };
 */
    NSAffineTransformStruct transformStruct = *(NSAffineTransformStruct*)&aTransform;
    NSAffineTransform *t = [NSAffineTransform transform];
    t.transformStruct = transformStruct;
    [self transformUsingAffineTransform:t];
}

- (CGPathRef)CGPath
{
    NSInteger i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

- (void)addCurveToPoint:(NSPoint)endPoint controlPoint1:(NSPoint)controlPoint1 controlPoint2:(NSPoint)controlPoint2
{
    [self curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}
@end
