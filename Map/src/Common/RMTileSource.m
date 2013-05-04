//
//  RMTileSource.m
//  MacMapView
//
//  Created by David Bainbridge on 5/3/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "RMTileSource.h"
#import "RMTileImage.h"
#import "RMTileCacheBase.h"

#define IS_VALID_TILE_IMAGE(image) (image != nil && [image isKindOfClass:[NSImage class]])

@interface RMTileSource()

@end

@implementation RMTileSource

- (id)init
{
    self = [super init];
    if (self) {
        _cacheable = YES;
        _opaque = YES;
        _missingTilesDepth = 1;
    }
    return self;
}

- (NSImage *)imageForTile:(RMTile)tile inCache:(RMTileCacheBase *)tileCache options:(RMImageForTileOptions)mask withBlock:(void (^)(NSImage *tileImage))imageBlock;
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
}

- (BOOL)tileSourceHasTile:(RMTile)tile
{
    return YES;
}

- (NSUInteger)tileSideLength
{
    return kDefaultTileSize;
}

- (void)cancelAllDownloads
{
}

- (void)didReceiveMemoryWarning
{
    LogMethod();
}

- (NSString *)uniqueTilecacheKey
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
}

- (NSString *)shortName
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
}

- (NSString *)longDescription
{
	return [self shortName];
}

- (NSString *)shortAttribution
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
}

- (NSString *)longAttribution
{
	return [self shortAttribution];
}

- (NSImage *)imageForMissingTile:(RMTile)tile fromCache:(RMTileCacheBase *)tileCache
{
    NSImage *tileImage;
    
    if (self.missingTilesDepth == 0)
    {
        tileImage = [RMTileImage errorTile];
    }
    else
    {
        NSUInteger currentTileDepth = 1;
        NSUInteger currentZoom = tile.zoom - currentTileDepth;
        
        // tries to return lower zoom level tiles if a tile cannot be found
        while ( !tileImage && currentZoom >= self.minZoom && currentTileDepth <= self.missingTilesDepth)
        {
            float nextX = tile.x / powf(2.0, (float)currentTileDepth),
            nextY = tile.y / powf(2.0, (float)currentTileDepth);
            float nextTileX = floor(nextX),
            nextTileY = floor(nextY);
            RMTile nextTile = RMTileMake((int)nextTileX, (int)nextTileY, currentZoom);
 //           tileImage = [self imageForTile:tile inCache:tileCache options:0 withBlock:nil];
            tileImage = [tileCache cachedImage:nextTile withCacheKey:[self uniqueTilecacheKey]];
            
            if (IS_VALID_TILE_IMAGE(tileImage))
            {
                
                // crop
                float cropSize = 1.0 / powf(2.0, (float)currentTileDepth);
                
                CGRect cropBounds = CGRectMake(tileImage.size.width * (nextX - nextTileX),
                                               tileImage.size.height * (nextY - nextTileY),
                                               tileImage.size.width * cropSize,
                                               tileImage.size.height * cropSize);
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([tileImage CGImage], cropBounds);
                tileImage = [NSImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                break;
            }
            else
            {
                tileImage = nil;
            }
            
            currentTileDepth++;
            currentZoom = tile.zoom - currentTileDepth;
        }
    }
    
    return tileImage;
}

@end
