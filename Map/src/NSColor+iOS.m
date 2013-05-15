//
//  NSColor+iOS.m
//  CalloutViewSample OS X
//
//  Created by David Bainbridge on 5/9/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "NSColor+iOS.h"

@implementation NSColor (iOS)
+ (NSColor *)colorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
{
    return [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
}
@end
