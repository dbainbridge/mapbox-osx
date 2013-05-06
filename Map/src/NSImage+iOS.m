//
//  NSImage+iOS.m
//  MacMapView
//
//  Created by David Bainbridge on 5/1/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "NSImage+iOS.h"

NSData *NSImagePNGRepresentation(NSImage *image)
{
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData *data = [imageRep representationUsingType: NSPNGFileType properties: nil];

    return data;
}

@implementation NSImage (iOS)
- (CGImageRef)CGImage
{
    return [self CGImageForProposedRect:nil context:nil hints:nil];
}

+ (NSImage *)imageWithData:(NSData *)imageData;
{
    return [[NSImage alloc] initWithData:imageData];
}

+ (NSImage *)imageWithContentsOfFile:(NSString *)path
{
    return path ? [[self alloc] initWithContentsOfFile:path] : nil;
}

+ (NSImage *)imageWithCGImage:(CGImageRef)imageRef
{
    NSSize size = NSMakeSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    return [[self alloc] initWithCGImage:imageRef size:size];
}

- (void)drawInRect:(CGRect)rect
{
    [self drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
}

- (void)drawAtPoint:(CGPoint)point
{
    [self drawInRect:(CGRect){point, self.size}];
}

@end
