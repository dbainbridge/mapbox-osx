//
//  RMUIScrollView.m
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import "RMUIScrollView.h"

@implementation RMUIScrollView
@synthesize contentOffset ;
//@synthesize contentSize;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentBoundsDidChange:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:self.contentView];
         */
    }
    
    return self;
}

- (void)dealloc
{
 //   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentBoundsDidChange:(NSNotification *)notification
{
    NSLog(@"hello");
}

- (CGSize)contentSize
{
    return [[self documentView] bounds].size;
}

- (void)setContentSize:(CGSize)theContentSize
{
    [[self documentView] setBoundsSize:theContentSize];
//    [[self documentView] setSize:theContentSize];
}

- (CGPoint)contentOffset
{
    return [self documentVisibleRect].origin;
}

- (void)setContentOffset:(CGPoint)theOffset
{
    [self setContentOffset:theOffset animated:NO];
}

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
    /*
    if (animated) {
        UIScrollViewAnimationScroll *animation = [[UIScrollViewAnimationScroll alloc] initWithScrollView:self
                                                                                       fromContentOffset:self.contentOffset
                                                                                         toContentOffset:theOffset
                                                                                                duration:UIScrollViewAnimationDuration
                                                                                                   curve:UIScrollViewAnimationScrollCurveLinear];
        [self _setScrollAnimation:animation];
        [animation release];
    } else*/ {
        contentOffset.x = round(theOffset.x);
        contentOffset.y = round(theOffset.y);
        
        /*
        CGRect bounds = self.bounds;
        bounds.origin.x = contentOffset.x+_contentInset.left;
        bounds.origin.y = contentOffset.y+_contentInset.top;
        self.bounds = bounds;
        */
        [[self documentView] scrollPoint:contentOffset];
        
       // [self _updateScrollers];
        //[self setNeedsLayout];
        
        /*
        if (_delegateCan.scrollViewDidScroll) {
            [_delegate scrollViewDidScroll:self];
        }
         */
    }
}

- (void)_updateScrollers
{
    /*
    _verticalScroller.contentSize = _contentSize.height;
    _verticalScroller.contentOffset = _contentOffset.y;
    _horizontalScroller.contentSize = _contentSize.width;
    _horizontalScroller.contentOffset = _contentOffset.x;
    
    _verticalScroller.hidden = !self._canScrollVertical;
    _horizontalScroller.hidden = !self._canScrollHorizontal;
     */
}

- (void)zoomWithFactor:(float)zoomFactor
{
//    if (self.zoomScale > [sender floatValue]) // then we are zooming in
    {
        //float zoomFactor = 1 + self.zoomScale - [sender floatValue];
        //float zoomFactor = 2.0;
        
        //oldZoomValue = [sender floatValue];
        
        NSRect visible = [self documentVisibleRect];
        NSRect newrect = NSInsetRect(visible, NSWidth(visible)*(1 - 1/zoomFactor)/2.0, NSHeight(visible)*(1 - 1/zoomFactor)/2.0);
        NSRect frame = [self.documentView frame];
        
        [self.documentView scaleUnitSquareToSize:NSMakeSize(zoomFactor, zoomFactor)];
        [self.documentView setFrame:NSMakeRect(0, 0, frame.size.width * zoomFactor, frame.size.height * zoomFactor)];
        //[[self documentView] scrollPoint:newrect.origin];
        
    }
}
- (void)scrollPointToCentre:(NSPoint) aPoint
{
	// given a point in view coordinates, the view is scrolled so that the point is centred in the
	// current document view
	
	NSRect  fr = [self documentVisibleRect];
	NSPoint sp;
	
	sp.x = aPoint.x - ( fr.size.width / 2.0 );
	sp.y = aPoint.y - ( fr.size.height / 2.0 );
	
	[self scrollPoint:sp];
}

- (void)zoomToRect:(CGRect)aRect animated:(BOOL)animated
{
	NSRect  fr = [self documentVisibleRect];
	NSPoint cp;
	
	float sx, sy;
	
	sx = fr.size.width / aRect.size.width;
	sy = fr.size.height / aRect.size.height;
	
	cp.x = aRect.origin.x + aRect.size.width / 2.0;
	cp.y = aRect.origin.y + aRect.size.height / 2.0;
	
	[self zoomWithFactor:MIN( sx, sy )];
    [self scrollPointToCentre:cp];
    
}


@end
