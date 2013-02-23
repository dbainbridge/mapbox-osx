//
//  RMMapStatWindowController.h
//  MacMapView
//
//  Created by David Bainbridge on 2/23/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RMMapView;

@interface RMMapStatWindowController : NSWindowController
@property (nonatomic, weak) RMMapView *mapView;
@end
