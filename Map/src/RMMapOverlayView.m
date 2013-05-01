//
//  RMMapOverlayView.m
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import "RMMapOverlayView.h"
//#import "RMAnnotation.h"
#import "RMPixel.h"
#import "RMMapView.h"
#import "RMUserLocation.h"

@implementation RMMapOverlayView

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self setLayer:[CAScrollLayer layer]];
    [self setWantsLayer:YES];
    
    self.layer.masksToBounds = NO;

    NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                       [NSNull null], @"onOrderOut",
                                       [NSNull null], @"sublayers",
                                       [NSNull null], @"contents",
                                       [NSNull null], @"bounds",
                                       [NSNull null], @"position",
                                       [NSNull null], @"sublayers",
                                       nil];
    self.layer.actions = newActions;

    return self;
}

- (NSUInteger)sublayersCount
{
    return [self.layer.sublayers count];
}

- (void)addSublayer:(CALayer *)aLayer
{
    [self.layer addSublayer:aLayer];
}

- (void)insertSublayer:(CALayer *)aLayer atIndex:(unsigned)index
{
    [self.layer insertSublayer:aLayer atIndex:index];
}

- (void)insertSublayer:(CALayer *)aLayer below:(CALayer *)sublayer
{
    [self.layer insertSublayer:aLayer below:sublayer];
}

- (void)insertSublayer:(CALayer *)aLayer above:(CALayer *)sublayer
{
    [self.layer insertSublayer:aLayer above:sublayer];
}

- (void)moveLayersBy:(CGPoint)delta
{
//    NSLog(@"moveLayersBy: %@", NSStringFromCGPoint(delta));
    [self.layer scrollPoint:CGPointMake(-delta.x, -delta.y)];
//    [self.layer scrollPoint:CGPointMake(0,0)];
}

- (CALayer *)overlayHitTest:(CGPoint)point
{
    return NO;
//TODO: FIX ME
    /*
    RMMapView *mapView = ((RMMapView *)self.superview);
    
    // Here we be sure to hide disabled but visible annotations' layers to
    // avoid touch events, then re-enable them after scoring the hit. We
    // also show the user location if enabled and we're in tracking mode,
    // since its layer is hidden and we want a possible hit.
    //
    NSPredicate *annotationPredicate = [NSPredicate predicateWithFormat:@"SELF.enabled = NO AND SELF.layer != %@ AND SELF.layer.isHidden = NO", [NSNull null]];
    
    NSArray *disabledVisibleAnnotations = [mapView.annotations filteredArrayUsingPredicate:annotationPredicate];
    
    for (RMAnnotation *annotation in disabledVisibleAnnotations)
        annotation.layer.hidden = YES;
    
    if (mapView.userLocation.enabled && mapView.userTrackingMode == RMUserTrackingModeFollowWithHeading)
        mapView.userLocation.layer.hidden = NO;
    
    CALayer *hit = [self.layer hitTest:point];
    
    if (mapView.userLocation.enabled && mapView.userTrackingMode == RMUserTrackingModeFollowWithHeading)
        mapView.userLocation.layer.hidden = YES;
    
    for (RMAnnotation *annotation in disabledVisibleAnnotations)
        annotation.layer.hidden = NO;
    
    return hit;
     */
}

@end
