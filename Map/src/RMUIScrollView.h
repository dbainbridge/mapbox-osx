//
//  RMUIScrollView.h
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import <Cocoa/Cocoa.h>
#import "NSView+UIView.h"
#import "UIGeometry.h"



@interface RMUIScrollView : NSScrollView

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated;
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;
- (CGSize)contentSize;
- (void)setContentSize:(CGSize)theContentSize;
- (void)zoomWithFactor:(float)zoomFactor;
- (void)zoomToScale:(float)zoomScale;
- (void)scrollPointToCentre:(NSPoint)aPoint;


//@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic) float maximumZoomScale;
@property (nonatomic) float minimumZoomScale;
@property (nonatomic) float zoomScale;
@property (nonatomic, readonly, getter=isZooming) BOOL zooming;


@end
