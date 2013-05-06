//
//  NSString+iOS.h
//  MacMapView
//
//  Created by David Bainbridge on 5/1/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NSString *NSStringFromCGPoint(CGPoint p);
NSString *NSStringFromCGRect(CGRect r);
NSString *NSStringFromCGSize(CGSize s);

@interface NSString (iOS)
- (CGSize)sizeWithFont:(NSFont *)font;
- (void)drawInRect:(CGRect)rect withFont:(NSFont *)font;
- (void)drawAtPoint:(NSPoint)point withFont:(NSFont *)font;

@end
