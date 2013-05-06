//
//  NSString+iOS.m
//  MacMapView
//
//  Created by David Bainbridge on 5/1/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "NSString+iOS.h"

NSString *NSStringFromCGPoint(CGPoint p)
{
    return NSStringFromPoint(NSPointFromCGPoint(p));
}

NSString *NSStringFromCGRect(CGRect r)
{
    return NSStringFromRect(NSRectFromCGRect(r));
}

NSString *NSStringFromCGSize(CGSize s)
{
    return NSStringFromSize(NSSizeFromCGSize(s));
}


@implementation NSString (iOS)

- (CGSize)sizeWithFont:(NSFont *)font
{
    return [self sizeWithAttributes:[NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName]];
}

- (void)drawInRect:(CGRect)rect withFont:(NSFont *)font
{
    [self drawInRect:rect withAttributes:[NSDictionary dictionaryWithObject:font
                                                                     forKey:NSFontAttributeName]];
}

- (void)drawAtPoint:(NSPoint)point withFont:(NSFont *)font
{
    [self drawAtPoint:point withAttributes:[NSDictionary dictionaryWithObject:font
                                                                       forKey:NSFontAttributeName]];
}
@end
