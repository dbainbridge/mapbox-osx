//
//  RMTileSource.h
//  MacMapView
//
//  Created by David Bainbridge on 5/3/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import "RMFoundation.h"
#import "RMGlobalConstants.h"

#define RMTileRequested @"RMTileRequested"
#define RMTileRetrieved @"RMTileRetrieved"

#define kDefaultTileSize 256

@class RMFractalTileProjection, RMTileCacheBase, RMProjection, RMTileImage;

@protocol RMMercatorToTileProjection;


@interface RMTileSource : NSObject
/** @name Configuring the Supported Zoom Levels */

/** The minimum zoom level supported by the tile source. */
@property (nonatomic, assign) float minZoom;

/** The maximum zoom level supported by the tile source. */
@property (nonatomic, assign) float maxZoom;

/** A Boolean value indicating whether the tiles from this source should be cached. */
@property (nonatomic, assign, getter=isCacheable) BOOL cacheable;

/** A Boolean value indicating whether the tiles from this source are opaque. Setting this correctly is important when using RMCompositeSource so that alpha transparency can be preserved when compositing tile images. */
@property (nonatomic, assign, getter=isOpaque) BOOL opaque;

@property (nonatomic, readonly) RMFractalTileProjection *mercatorToTileProjection;
@property (nonatomic, readonly) RMProjection *projection;

/** @name Querying the Bounds */

/** The bounding box that the tile source provides coverage for. */
@property (nonatomic, readonly) RMSphericalTrapezium latitudeLongitudeBoundingBox;

/** @name Configuring Caching */

/** A unique string representing the tile source in the cache in order to distinguish it from other tile sources. */
@property (nonatomic, readonly) NSString *uniqueTilecacheKey;

/** @name Configuring Tile Size */

/** The number of pixels along the side of a tile image for this source. */
@property (nonatomic, readonly) NSUInteger tileSideLength;

/** @name Configuring Descriptive Properties */

/** A short version of the tile source's name. */
@property (nonatomic, readonly) NSString *shortName;

/** An extended version of the tile source's description. */
@property (nonatomic, readonly) NSString *longDescription;

/** A short version of the tile source's attribution string. */
@property (nonatomic, readonly) NSString *shortAttribution;

/** An extended version of the tile source's attribution string. */
@property (nonatomic, readonly) NSString *longAttribution;

#pragma mark -

/** @name Supplying Tile Images */

/** Provide an image for a given tile location using a given cache.
 *   @param tile The map tile in question.
 *   @param tileCache A tile cache to check first when providing the image.
 *   @return An image to display. */
- (NSImage *)imageForTile:(RMTile)tile inCache:(RMTileCacheBase *)tileCache withBlock:(void (^)(NSImage *tileImage))imageBlock;
//- (NSImage *)imageForTile:(RMTile)tile inCache:(RMTileCacheBase *)tileCache;

/** Check if the tile source can provide the requested tile.
 *  @param tile The map tile in question.
 *  @return A Boolean value indicating whether the tile source can provide the requested tile. */
- (BOOL)tileSourceHasTile:(RMTile)tile;

- (void)cancelAllDownloads;

- (void)didReceiveMemoryWarning;

@end
