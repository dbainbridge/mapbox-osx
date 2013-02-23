//
//  RMMapStatWindowController.h
//  MacMapView
//
//  Created by David Bainbridge on 2/23/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

@class RMMapView;

@interface RMMapStatWindowController : NSWindowController
@property (nonatomic, weak) RMMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

- (void)startTrackingMap;
@end
