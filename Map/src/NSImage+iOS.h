//
//  NSImage+iOS.h
//  MacMapView
//
//  Created by David Bainbridge on 5/1/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSData *NSImagePNGRepresentation(NSImage *image);

@interface NSImage (iOS)
+ (NSImage *)imageWithData:(NSData *)imageData;
- (CGImageRef)CGImage;
+ (NSImage *)imageWithContentsOfFile:(NSString *)path;
+ (NSImage *)imageWithCGImage:(CGImageRef)imageRef;

- (void)drawInRect:(CGRect)rect;
- (void)drawAtPoint:(CGPoint)point;

@end
