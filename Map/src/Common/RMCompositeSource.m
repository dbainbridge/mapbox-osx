//
//  RMCompositeSource.m
//  MapView
//
// Copyright (c) 2008-2012, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMCompositeSource.h"
#import "RMTileCacheMulti.h"

@implementation RMCompositeSource
{
    NSArray *_tileSources;
    NSString *_uniqueTilecacheKey;
}

- (id)initWithTileSources:(NSArray *)tileSources tileCacheKey:(NSString *)tileCacheKey
{
    if (!(self = [super init]))
        return nil;

    NSAssert(tileSources != nil && [tileSources count], @"Empty host parameter not allowed");

    _tileSources = [tileSources copy];

    if (tileCacheKey)
    {
        _uniqueTilecacheKey = tileCacheKey;
    }
    else
    {
        self.cacheable = NO;
        _uniqueTilecacheKey = nil;
    }

    float tileSourcesMinZoom = FLT_MAX, tileSourcesMaxZoom = FLT_MIN;
    BOOL tileSourcesAreOpaque = YES;

    for (RMTileSource *currentTileSource in _tileSources)
    {
        tileSourcesMinZoom = MIN(tileSourcesMinZoom, currentTileSource.minZoom);
        tileSourcesMaxZoom = MAX(tileSourcesMaxZoom, currentTileSource.maxZoom);

        if ( ! currentTileSource.isOpaque)
            tileSourcesAreOpaque = NO;
    }

    self.minZoom = tileSourcesMinZoom;
    self.maxZoom = tileSourcesMaxZoom;
    self.opaque  = tileSourcesAreOpaque;

    return self;
}

- (NSArray *)tileSources
{
    return [_tileSources copy];
}

- (NSString *)uniqueTilecacheKey
{
    return _uniqueTilecacheKey;
}

- (NSString *)shortName
{
	return @"Generic Map Source";
}

- (NSString *)longDescription
{
	return @"Generic Map Source";
}

- (NSString *)shortAttribution
{
	return @"n/a";
}

- (NSString *)longAttribution
{
	return @"n/a";
}

- (NSImage *)imageForTile:(RMTile)tile inCache:(RMTileCacheBase *)tileCache options:(RMImageForTileOptions)mask withBlock:(void (^)(NSImage *))imageBlock
{
    NSImage *image = nil;

	tile = [[self mercatorToTileProjection] normaliseTile:tile];

    if (self.isCacheable)
    {
        image = [tileCache cachedImage:tile withCacheKey:[self uniqueTilecacheKey]];

        if (image)
            return image;
    }

    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RMTileRequested object:[NSNumber numberWithUnsignedLongLong:RMTileKey(tile)]];
    });

    NSMutableArray *tileImages = [NSMutableArray arrayWithCapacity:[_tileSources count]];

    for (NSUInteger p = 0; p < [_tileSources count]; ++p)
        [tileImages addObject:[NSNull null]];

    for (NSInteger u = [_tileSources count]-1; u >=0 ; --u)
    {
        RMTileSource *tileSource = [_tileSources objectAtIndex:u];

        if (tile.zoom < tileSource.minZoom || tile.zoom > tileSource.maxZoom || ![tileSource tileSourceHasTile:tile])
            continue;

        NSImage *tileImage = [tileSource imageForTile:tile inCache:tileCache options:NO withBlock:nil];

        if (tileImage)
        {
            [tileImages replaceObjectAtIndex:u withObject:tileImage];

            if (tileSource.isOpaque)
                break;
        }
    }

    // composite the collected images together
    //
    for (NSImage *tileImage in tileImages)
    {
        if ( ! [tileImage isKindOfClass:[NSImage class]])
            continue;

        if (image != nil)
        {
            [image lockFocus];
            //UIGraphicsBeginImageContext(image.size);
            //[image drawAtPoint:CGPointMake(0,0)];
            [tileImage drawAtPoint:CGPointMake(0,0)];

            //image = UIGraphicsGetCGImageFromCurrentImageContext();
            //UIGraphicsEndImageContext();
            [image unlockFocus];
        }
        else
        {
            image = tileImage;
        }
    }

    if (image && self.isCacheable)
        [tileCache addImage:image forTile:tile withCacheKey:[self uniqueTilecacheKey]];

    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:[NSNumber numberWithUnsignedLongLong:RMTileKey(tile)]];
    });

    return image;
}

@end
