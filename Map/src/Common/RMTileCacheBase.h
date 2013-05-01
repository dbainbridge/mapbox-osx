//
//  RMTileCacheBase.h
//  MacMapView
//
//  Created by David Bainbridge on 4/30/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTile.h"

typedef enum : short {
	RMCachePurgeStrategyLRU,
	RMCachePurgeStrategyFIFO,
} RMCachePurgeStrategy;

struct RMTileCacheRespondsTo{
    unsigned int addImageForTileWithCacheKey:1;
    unsigned int addImageForTileWithDataWithCacheKey:1;
};

typedef struct RMTileCacheRespondsTo RMTileCacheRespondsTo;

NS_INLINE NSNumber *RMTileCacheHash(RMTile tile) {
	return [NSNumber numberWithUnsignedLongLong:RMTileKey(tile)];
}


@interface RMTileCacheBase : NSObject
/** @name Querying the Cache */

/** Returns an image from the cache if it exists.
 *   @param tile A desired RMTile.
 *   @param cacheKey The key representing a certain cache.
 *   @return An image of the tile that can be used to draw a portion of the map. */
- (NSImage *)cachedImage:(RMTile)tile withCacheKey:(NSString *)cacheKey;

- (void)didReceiveMemoryWarning;


/** @name Adding to the Cache */

/** Adds a tile image to specified cache.
 *   @param image A tile image to be cached.
 *   @param tile The RMTile describing the map location of the image.
 *   @param cacheKey The key representing a certain cache. */
- (void)addImage:(NSImage *)image forTile:(RMTile)tile withCacheKey:(NSString *)cacheKey;

- (void)addImage:(NSImage *)image forTile:(RMTile)tile withData:(NSData *)tileData withCacheKey:(NSString *)cacheKey;

/** @name Clearing the Cache */

/** Removes all tile images from a cache. */
- (void)removeAllCachedImages;
- (void)removeAllCachedImagesForCacheKey:(NSString *)cacheKey;

/** @name Identifying Cache Objects */

@property (nonatomic, assign) RMTileCacheRespondsTo repondsTo;

@end
