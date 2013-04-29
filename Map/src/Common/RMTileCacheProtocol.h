//
//  RMTileCacheProtocol.h
//  MacMapView
//
//  Created by David Bainbridge on 4/29/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The RMTileCache protocol describes behaviors that tile caches should implement. */
@protocol RMTileCacheProtocol <NSObject>

/** @name Querying the Cache */

/** Returns an image from the cache if it exists.
 *   @param tile A desired RMTile.
 *   @param cacheKey The key representing a certain cache.
 *   @return An image of the tile that can be used to draw a portion of the map. */
- (UIImage *)cachedImage:(RMTile)tile withCacheKey:(NSString *)cacheKey;

- (void)didReceiveMemoryWarning;

@optional

/** @name Adding to the Cache */

/** Adds a tile image to specified cache.
 *   @param image A tile image to be cached.
 *   @param tile The RMTile describing the map location of the image.
 *   @param cacheKey The key representing a certain cache. */
- (void)addImage:(UIImage *)image forTile:(RMTile)tile withCacheKey:(NSString *)cacheKey;

/** @name Clearing the Cache */

/** Removes all tile images from a cache. */
- (void)removeAllCachedImages;
- (void)removeAllCachedImagesForCacheKey:(NSString *)cacheKey;

@end
