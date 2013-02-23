//
//  TestView.m
//  MacMapView
//
//  Created by David Bainbridge on 2/18/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer = [CATiledLayer layer];
 //       self.wantsLayer = YES;
//        self.layer.delegate = self;
     }
    
    return self;
}

- (void)awakeFromNib
{
//    self.layer = [CATiledLayer layer];
//    self.wantsLayer = YES;
//    self.layer.delegate = self;
   
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"hello");
}

@end
