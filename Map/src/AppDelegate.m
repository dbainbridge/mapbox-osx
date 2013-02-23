//
//  AppDelegate.m
//  MacMapView
//
//  Created by David Bainbridge on 2/18/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "AppDelegate.h"
#import "RMMapView.h"
#import "RMMapBoxSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMOpenSeaMapSource.h"

#import "TestView.h"

#define kNormalMapID @"examples.map-z2effxa8"
#define kRetinaMapID @"examples.map-zswgei2n"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSView *myView = [self.window contentView];
    RMMapBoxSource *onlineSource = [[RMMapBoxSource alloc] initWithMapID:kNormalMapID];
    //RMOpenStreetMapSource *onlineSource = [[RMOpenStreetMapSource alloc] init];
    //RMOpenSeaMapSource *onlineSource = [[RMOpenSeaMapSource alloc] init];
   
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:myView.bounds andTilesource:onlineSource];

    mapView.debugTiles = YES;
    CGPoint point = {0,0};
    [myView addSubview:mapView];
    [mapView zoomByFactor:8 near:point animated:NO];

}

- (void)awakeFromNib
{
/*    NSView *myView = [self.window contentView];

    NSView *newView = [[TestView alloc] initWithFrame:myView.bounds];
    self.testView.layer = [CATiledLayer layer];
    self.testView.wantsLayer = YES;
    [self.testView addSubview:newView];
    [self.testView.layer setNeedsDisplay];
    self.testView.layer.delegate = self;
 */
    
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"hello");
}

@end
