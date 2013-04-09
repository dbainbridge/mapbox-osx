//
//  AppDelegate.h
//  MacMapView
//
//  Created by David Bainbridge on 2/18/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RMMapViewDelegate.h"

@class RMMapStatWindowController;
@interface AppDelegate : NSObject <NSApplicationDelegate, RMMapViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSView *testView;
@property (nonatomic, strong) RMMapStatWindowController *statWindowController;
@end
