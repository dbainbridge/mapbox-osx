//
//  RMMapStatWindowController.m
//  MacMapView
//
//  Created by David Bainbridge on 2/23/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "RMMapStatWindowController.h"
#import "RMMapView.h"

@interface RMMapStatWindowController ()

@end

@implementation RMMapStatWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)windowNibName
{
    return @"RMMapStatWindow";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)startTrackingMap
{
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.mapView.frame
                                                options: ( NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                  owner:self userInfo:nil];
    [self.mapView addTrackingArea:trackingArea];

}

- (void)mouseMoved:(NSEvent *)theEvent {
    NSPoint mousePoint = [self.mapView convertPoint:[theEvent locationInWindow] fromView:nil];
    self.location = [self.mapView pixelToCoordinate:mousePoint];
    self.latitude = self.location.latitude;
    self.longitude = self.location.longitude;
    
    NSLog(@"eyeCenter: %@", NSStringFromPoint(mousePoint));
}
@end
