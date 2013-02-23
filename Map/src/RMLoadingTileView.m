//
//  RMLoadingTileView.m
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import "RMLoadingTileView.h"

@implementation RMLoadingTileView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _contentView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 3, frame.size.height * 3)];
//        [self addSubview:_contentView];
        
        [self setMapZooming:NO];
        
 //       self.userInteractionEnabled = NO;
//        self.showsHorizontalScrollIndicator = NO;
//        self.showsVerticalScrollIndicator = NO;
    }
    
    return self;
}

- (void)setMapZooming:(BOOL)zooming
{
    /*
    if (zooming)
    {
        _contentView.backgroundColor = [UIColor colorWithPatternImage:[RMMapView resourceImageNamed:@"LoadingTileZoom.png"]];
    }
    else
    {
        _contentView.backgroundColor = [UIColor colorWithPatternImage:[RMMapView resourceImageNamed:@"LoadingTile.png"]];
        
        _contentView.frame = CGRectMake(0, 0, self.frame.size.width * 3, self.frame.size.height * 3);
        self.contentSize = self.contentView.bounds.size;
        self.contentOffset = CGPointMake(self.frame.size.width, self.frame.size.height);
    }
    */
    _mapZooming = zooming;
}

@end
