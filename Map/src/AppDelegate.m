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
#import "RMMapStatWindowController.h"
#import "RMAnnotation.h"
#import "RMMapLayer.h"

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
    mapView.delegate = self;
    
    mapView.debugTiles = NO;
    CGPoint point = {0,0};
    [myView addSubview:mapView];
//    [mapView zoomByFactor:8 near:point animated:NO];
/*
    self.statWindowController = [[RMMapStatWindowController alloc] init];
    [self.statWindowController showWindow:nil];
    self.statWindowController.mapView = mapView;
    [self.statWindowController startTrackingMap];
    */
    RMAnnotation* annotation = [[RMAnnotation alloc] initWithMapView: mapView
                                                          coordinate: CLLocationCoordinate2DMake(47.38344955, -95.23297119)
                                                            andTitle: @""];
    [mapView addAnnotation: annotation];
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

- (RMMapLayer*)mapView: (RMMapView *)mapView layerForAnnotation: (RMAnnotation *)annotation
{
//    UIImage* treeImage = [UIImage imageNamed: @"trackingdot.png"];
    NSImage *image = [NSImage imageNamed:@"TrackingDot"];
    RMMapLayer* mapLayer = [[RMMapLayer alloc] init];
    mapLayer.anchorPoint = CGPointZero;
    mapLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    mapLayer.position = CGPointZero;
    mapLayer.contents = (__bridge id)([image CGImageForProposedRect:NULL context:NULL hints:NULL]);
    mapLayer.masksToBounds = NO;
    
    mapLayer.backgroundColor = [NSColor greenColor].CGColor;
    mapLayer.borderColor = [NSColor redColor].CGColor;
    mapLayer.borderWidth = 1.0;
    
    return mapLayer;
}
@end
