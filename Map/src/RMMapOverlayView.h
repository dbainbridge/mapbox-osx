//
//  RMMapOverlayView.h
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import <Cocoa/Cocoa.h>

@interface RMMapOverlayView : NSView
- (unsigned)sublayersCount;

- (void)addSublayer:(CALayer *)aLayer;
- (void)insertSublayer:(CALayer *)aLayer atIndex:(unsigned)index;

- (void)insertSublayer:(CALayer *)aLayer below:(CALayer *)sublayer;
- (void)insertSublayer:(CALayer *)aLayer above:(CALayer *)sublayer;

- (void)moveLayersBy:(CGPoint)delta;

- (CALayer *)overlayHitTest:(CGPoint)point;

@end
