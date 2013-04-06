//
//  RMMapStatWindowController.h
//  MacMapView
//
//  Created by David Bainbridge on 2/23/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import "RMFoundation.h"

@class RMMapView;

@interface RMMapStatWindowController : NSWindowController
@property (nonatomic, weak) RMMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign) RMProjectedPoint centerPoint;

@property (nonatomic, assign) double centerX;
@property (nonatomic, assign) double centerY;

@property (nonatomic, assign) double projectedX;
@property (nonatomic, assign) double projectedY;

- (void)startTrackingMap;
@end
