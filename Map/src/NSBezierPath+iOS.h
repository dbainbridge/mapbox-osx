//
//  NSBezierPath+iOS.h
//  CalloutViewSample OS X
//
//  Created by David Bainbridge on 5/9/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (iOS)
- (void)addLineToPoint:(NSPoint)aPoint;
- (void)addArcWithCenter:(NSPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;
- (void)appendPath:(NSBezierPath *)aPath;
- (void)applyTransform:(CGAffineTransform)aTransform;
- (CGPathRef)CGPath;
- (void)addCurveToPoint:(NSPoint)endPoint controlPoint1:(NSPoint)controlPoint1 controlPoint2:(NSPoint)controlPoint2;

@end
