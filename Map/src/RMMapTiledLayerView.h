//
//  RMMapTiledLayerView.h
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import "RMTileSource.h"

@class RMMapView;

@interface RMMapTiledLayerView : NSView

@property (nonatomic, assign) BOOL useSnapshotRenderer;

@property (nonatomic, readonly) RMTileSource *tileSource;

- (id)initWithFrame:(CGRect)frame mapView:(RMMapView *)aMapView forTileSource:(RMTileSource *)aTileSource;

@end
