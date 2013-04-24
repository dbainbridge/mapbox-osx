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

#define kNormalMapID @"examples.map-z2effxa8"
#define kRetinaMapID @"examples.map-zswgei2n"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSView *myView = [self.window contentView];
    NSString *myID = kNormalMapID;
    RMMapBoxSource *onlineSource = [[RMMapBoxSource alloc] initWithMapID:myID];
   
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:myView.bounds andTilesource:onlineSource];
    mapView.delegate = self;
    
    mapView.debugTiles = NO;
    [myView addSubview:mapView];
    
//    [mapView zoomByFactor:8 near:point animated:NO];
/*
    self.statWindowController = [[RMMapStatWindowController alloc] init];
    [self.statWindowController showWindow:nil];
    self.statWindowController.mapView = mapView;
    [self.statWindowController startTrackingMap];
    */
    RMAnnotation* annotation = [[RMAnnotation alloc] initWithMapView: mapView
                                                          coordinate: CLLocationCoordinate2DMake(47.38344955, -94.23297119)
                                                            andTitle: @""];
    [mapView addAnnotation: annotation];
}

- (void)awakeFromNib
{
    
}

- (RMMapLayer*)mapView: (RMMapView *)mapView layerForAnnotation: (RMAnnotation *)annotation
{
    NSImage *image = [NSImage imageNamed:@"TrackingDot"];
    RMMapLayer* mapLayer = [[RMMapLayer alloc] init];
//    mapLayer.anchorPoint = CGPointZero;
    mapLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    mapLayer.position = CGPointZero;
    mapLayer.contents = (__bridge id)([image CGImageForProposedRect:NULL context:NULL hints:NULL]);
    mapLayer.masksToBounds = NO;
    
    return mapLayer;
}
@end
