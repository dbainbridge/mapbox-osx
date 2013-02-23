//
//  RMMapScrollView.h
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import <Cocoa/Cocoa.h>
#import "RMUIScrollView.h"

@class RMMapScrollView;

@protocol RMMapScrollViewDelegate <NSObject>

- (void)scrollView:(RMMapScrollView *)aScrollView correctedContentOffset:(inout CGPoint *)aContentOffset;
- (void)scrollView:(RMMapScrollView *)aScrollView correctedContentSize:(inout CGSize *)aContentSize;

@end

@interface RMMapScrollView : RMUIScrollView
@property (nonatomic, weak) id <RMMapScrollViewDelegate> mapScrollViewDelegate;

@end
