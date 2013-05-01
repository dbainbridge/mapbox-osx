//
//  NSString+iOS.h
//  MacMapView
//
//  Created by David Bainbridge on 5/1/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (iOS)
- (CGSize)sizeWithFont:(NSFont *)font;
- (void)drawInRect:(CGRect)rect withFont:(NSFont *)font;
- (void)drawAtPoint:(NSPoint)point withFont:(NSFont *)font;

@end
