//
//  RMTileCache.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
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

#import <sys/utsname.h>

#import "RMTileCacheMulti.h"
#import "RMMemoryCache.h"
#import "RMDatabaseCache.h"

#import "RMConfiguration.h"
#import "RMTileSource.h"

#import "RMTileCacheDownloadOperation.h"

@interface RMTileCacheMulti (Configuration)

- (RMMemoryCache *)memoryCacheWithConfig:(NSDictionary *)cfg;
- (RMDatabaseCache *)databaseCacheWithConfig:(NSDictionary *)cfg;

@end

@implementation RMTileCacheMulti
{
    NSMutableArray *_tileCaches;

    // The memory cache, if we have one
    // This one has its own variable because we want to propagate cache hits down in
    // the cache hierarchy up to the memory cache
    RMMemoryCache *_memoryCache;
    NSTimeInterval _expiryPeriod;

    dispatch_queue_t _tileCacheQueue;
    
    RMTileSource *_activeTileSource;
    NSOperationQueue *_backgroundFetchQueue;
}

@synthesize backgroundCacheDelegate=_backgroundCacheDelegate;

- (id)initWithExpiryPeriod:(NSTimeInterval)period
{
    if (!(self = [super init]))
        return nil;

    _tileCaches = [NSMutableArray new];
    _tileCacheQueue = dispatch_queue_create("routeme.tileCacheQueue", DISPATCH_QUEUE_CONCURRENT);

    _memoryCache = nil;
    _expiryPeriod = period;
    
    _backgroundCacheDelegate = nil;
    _activeTileSource = nil;
    _backgroundFetchQueue = nil;

    id cacheCfg = [[RMConfiguration configuration] cacheConfiguration];
    if (!cacheCfg)
        cacheCfg = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObject: @"memory-cache" forKey: @"type"],
                    [NSDictionary dictionaryWithObject: @"db-cache"     forKey: @"type"],
                    nil];

    for (id cfg in cacheCfg)
    {
        RMTileCacheBase *newCache = nil;

        @try {

            NSString *type = [cfg valueForKey:@"type"];

            if ([@"memory-cache" isEqualToString:type])
            {
                _memoryCache = [self memoryCacheWithConfig:cfg];
                continue;
            }

            if ([@"db-cache" isEqualToString:type])
                newCache = [self databaseCacheWithConfig:cfg];

            if (newCache)
                [self addCache:newCache];
            else
                RMLog(@"failed to create cache of type %@", type);

        }
        @catch (NSException * e) {
            RMLog(@"*** configuration error: %@", [e reason]);
        }
    }

    return self;
}

- (id)init
{
    if (!(self = [self initWithExpiryPeriod:0]))
        return nil;
    
    return self;
}

- (void)dealloc
{
    if (self.isBackgroundCaching)
        [self cancelBackgroundCache];
    
    dispatch_barrier_sync(_tileCacheQueue, ^{
         _memoryCache = nil;
         _tileCaches = nil;
    });
}

- (void)addCache:(RMTileCacheBase *)cache
{
    dispatch_barrier_async(_tileCacheQueue, ^{
        if ([cache isKindOfClass:[RMDatabaseCache class]])
            _databaseCache = (RMDatabaseCache *)cache;
        [_tileCaches addObject:cache];
    });
}

- (void)insertCache:(RMTileCacheBase *)cache atIndex:(NSUInteger)index
{
    dispatch_barrier_async(_tileCacheQueue, ^{
        if (index >= [_tileCaches count])
            [_tileCaches addObject:cache];
        else
            [_tileCaches insertObject:cache atIndex:index];
    });
}

- (NSArray *)tileCaches
{
    return [NSArray arrayWithArray:_tileCaches];
}

// Returns the cached image if it exists. nil otherwise.
- (NSImage *)cachedImage:(RMTile)tile withCacheKey:(NSString *)aCacheKey
{
    __block NSImage *image = [_memoryCache cachedImage:tile withCacheKey:aCacheKey];

    if (image)
        return image;

    // dbainbridge 05/06/2013 don't believe sync necessary here is each cache is syncing themselves
    // This is also called from non-main thread from displayLayer:inContext:
//    dispatch_sync(_tileCacheQueue, ^{
        for (RMTileCacheBase *cache in _tileCaches)
        {
            image = [cache cachedImage:tile withCacheKey:aCacheKey];
            
            if (image != nil)
            {
                [_memoryCache addImage:image forTile:tile withCacheKey:aCacheKey];
                break;
            }
        }

//    });

	return image;
}

- (void)addImage:(NSImage *)image forTile:(RMTile)tile withData:(NSData *)tileData withCacheKey:(NSString *)aCacheKey
{
    if (!image || !aCacheKey)
        return;
    
    [_memoryCache addImage:image forTile:tile withCacheKey:aCacheKey];
    
    // dbainbridge 05/06/2013 don't believe sync necessary here is each cache is syncing themselves
    // This is also called from non-main thread from displayLayer:inContext:
//    dispatch_sync(_tileCacheQueue, ^{
        for (RMTileCacheBase *cache in _tileCaches)
        {
            if (cache.repondsTo.addImageForTileWithDataWithCacheKey)
                [cache addImage:image forTile:tile withData:tileData withCacheKey:aCacheKey];
            else if (cache.repondsTo.addImageForTileWithCacheKey)
                [cache addImage:image forTile:tile withCacheKey:aCacheKey];
        }
        
//    });
    
}

- (void)addImage:(NSImage *)image forTile:(RMTile)tile withCacheKey:(NSString *)aCacheKey
{
    if (!image || !aCacheKey)
        return;

    [_memoryCache addImage:image forTile:tile withCacheKey:aCacheKey];

    dispatch_sync(_tileCacheQueue, ^{

        for (RMTileCacheBase *cache in _tileCaches)
        {	
            if (cache.repondsTo.addImageForTileWithCacheKey)
                [cache addImage:image forTile:tile withCacheKey:aCacheKey];
        }

    });
}

- (void)didReceiveMemoryWarning
{
	LogMethod();

    [_memoryCache didReceiveMemoryWarning];

    dispatch_sync(_tileCacheQueue, ^{

        for (RMTileCacheBase *cache in _tileCaches)
        {
            [cache didReceiveMemoryWarning];
        }

    });
}

- (void)removeAllCachedImages
{
    [_memoryCache removeAllCachedImages];

    dispatch_sync(_tileCacheQueue, ^{

        for (RMTileCacheBase *cache in _tileCaches)
        {
            [cache removeAllCachedImages];
        }

    });
}

- (void)removeAllCachedImagesForCacheKey:(NSString *)cacheKey
{
    [_memoryCache removeAllCachedImagesForCacheKey:cacheKey];

    dispatch_sync(_tileCacheQueue, ^{

        for (RMTileCacheBase *cache in _tileCaches)
        {
            [cache removeAllCachedImagesForCacheKey:cacheKey];
        }
    });
}

- (BOOL)isBackgroundCaching
{
    return (_activeTileSource || _backgroundFetchQueue);
}

- (void)beginBackgroundCacheForTileSource:(RMTileSource *)tileSource southWest:(CLLocationCoordinate2D)southWest northEast:(CLLocationCoordinate2D)northEast minZoom:(float)minZoom maxZoom:(float)maxZoom
{
    if (self.isBackgroundCaching)
        return;

    _activeTileSource = tileSource;
    
    _backgroundFetchQueue = [[NSOperationQueue alloc] init];
    [_backgroundFetchQueue setMaxConcurrentOperationCount:6];
    
    int   minCacheZoom = (int)minZoom;
    int   maxCacheZoom = (int)maxZoom;
    float minCacheLat  = southWest.latitude;
    float maxCacheLat  = northEast.latitude;
    float minCacheLon  = southWest.longitude;
    float maxCacheLon  = northEast.longitude;

    if (maxCacheZoom < minCacheZoom || maxCacheLat <= minCacheLat || maxCacheLon <= minCacheLon)
        return;

    int n, xMin, yMax, xMax, yMin;

    int totalTiles = 0;

    for (int zoom = minCacheZoom; zoom <= maxCacheZoom; zoom++)
    {
        n = pow(2.0, zoom);
        xMin = floor(((minCacheLon + 180.0) / 360.0) * n);
        yMax = floor((1.0 - (logf(tanf(minCacheLat * M_PI / 180.0) + 1.0 / cosf(minCacheLat * M_PI / 180.0)) / M_PI)) / 2.0 * n);
        xMax = floor(((maxCacheLon + 180.0) / 360.0) * n);
        yMin = floor((1.0 - (logf(tanf(maxCacheLat * M_PI / 180.0) + 1.0 / cosf(maxCacheLat * M_PI / 180.0)) / M_PI)) / 2.0 * n);

        totalTiles += (xMax + 1 - xMin) * (yMax + 1 - yMin);
    }

    [_backgroundCacheDelegate tileCache:self didBeginBackgroundCacheWithCount:totalTiles forTileSource:_activeTileSource];

    __block int progTile = 0;

    for (int zoom = minCacheZoom; zoom <= maxCacheZoom; zoom++)
    {
        n = pow(2.0, zoom);
        xMin = floor(((minCacheLon + 180.0) / 360.0) * n);
        yMax = floor((1.0 - (logf(tanf(minCacheLat * M_PI / 180.0) + 1.0 / cosf(minCacheLat * M_PI / 180.0)) / M_PI)) / 2.0 * n);
        xMax = floor(((maxCacheLon + 180.0) / 360.0) * n);
        yMin = floor((1.0 - (logf(tanf(maxCacheLat * M_PI / 180.0) + 1.0 / cosf(maxCacheLat * M_PI / 180.0)) / M_PI)) / 2.0 * n);

        for (int x = xMin; x <= xMax; x++)
        {
            for (int y = yMin; y <= yMax; y++)
            {
                RMTileCacheDownloadOperation *operation = [[RMTileCacheDownloadOperation alloc] initWithTile:RMTileMake(x, y, zoom)
                                                                                                forTileSource:_activeTileSource
                                                                                                   usingCache:self];

                __block RMTileCacheDownloadOperation *internalOperation = operation;

                [operation setCompletionBlock:^(void)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^(void)
                    {
                        if ( ! [internalOperation isCancelled])
                        {
                            progTile++;

                            [_backgroundCacheDelegate tileCache:self didBackgroundCacheTile:RMTileMake(x, y, zoom) withIndex:progTile ofTotalTileCount:totalTiles];

                            if (progTile == totalTiles)
                            {
                                 _backgroundFetchQueue = nil;

                                 _activeTileSource = nil;

                                [_backgroundCacheDelegate tileCacheDidFinishBackgroundCache:self];
                            }
                        }

                        internalOperation = nil;
                    });
                }];

                [_backgroundFetchQueue addOperation:operation];
            }
        }
    };
}

- (void)cancelBackgroundCache
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        @synchronized (self)
        {
            BOOL didCancel = NO;

            if (_backgroundFetchQueue)
            {
                [_backgroundFetchQueue cancelAllOperations];
                [_backgroundFetchQueue waitUntilAllOperationsAreFinished];
                 _backgroundFetchQueue = nil;

                didCancel = YES;
            }

            if (_activeTileSource)
                 _activeTileSource = nil;

            if (didCancel)
            {
                dispatch_sync(dispatch_get_main_queue(), ^(void)
                {
                    [_backgroundCacheDelegate tileCacheDidCancelBackgroundCache:self];
                });
            }
        }
    });
}

@end

#pragma mark -

@implementation RMTileCacheMulti (Configuration)

static NSMutableDictionary *predicateValues = nil;

- (NSDictionary *)predicateValues
{
    static dispatch_once_t predicateValuesOnceToken;

    dispatch_once(&predicateValuesOnceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);

        NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];

        predicateValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           [[UIDevice currentDevice] model], @"model",
                           machine, @"machine",
                           [[UIDevice currentDevice] systemName], @"systemName",
                           [NSNumber numberWithFloat:[[[UIDevice currentDevice] systemVersion] floatValue]], @"systemVersion",
                           [NSNumber numberWithInt:[[UIDevice currentDevice] userInterfaceIdiom]], @"userInterfaceIdiom",
                           nil];

        if ( ! ([machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"]))
        {
            NSNumber *machineNumber = [NSNumber numberWithFloat:[[[machine stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue]];

            if ( ! machineNumber)
                machineNumber = [NSNumber numberWithFloat:0.0];

            [predicateValues setObject:machineNumber forKey:@"machineNumber"];
        }
        else
        {
            [predicateValues setObject:[NSNumber numberWithFloat:0.0] forKey:@"machineNumber"];
        }

        // A predicate might be:
        // (self.model = 'iPad' and self.machineNumber >= 3) or (self.machine = 'x86_64')
        // See NSPredicate

//        NSLog(@"Predicate values:\n%@", [predicateValues description]);
    });

    return predicateValues;
}

- (RMMemoryCache *)memoryCacheWithConfig:(NSDictionary *)cfg
{
    NSUInteger capacity = 32;

	NSNumber *capacityNumber = [cfg objectForKey:@"capacity"];
	if (capacityNumber != nil)
        capacity = [capacityNumber unsignedIntegerValue];

    NSArray *predicates = [cfg objectForKey:@"predicates"];

    if (predicates)
    {
        NSDictionary *predicateValues = [self predicateValues];

        for (NSDictionary *predicateDescription in predicates)
        {
            NSString *predicate = [predicateDescription objectForKey:@"predicate"];
            if ( ! predicate)
                continue;

            if ( ! [[NSPredicate predicateWithFormat:predicate] evaluateWithObject:predicateValues])
                continue;

            capacityNumber = [predicateDescription objectForKey:@"capacity"];
            if (capacityNumber != nil)
                capacity = [capacityNumber unsignedIntegerValue];
        }
    }

    RMLog(@"Memory cache configuration: {capacity : %ld}", (NSUInteger)capacity);

	return [[RMMemoryCache alloc] initWithCapacity:capacity];
}

- (RMDatabaseCache *)databaseCacheWithConfig:(NSDictionary *)cfg
{
    BOOL useCacheDir = NO;
    RMCachePurgeStrategy strategy = RMCachePurgeStrategyFIFO;

    NSUInteger capacity = 1000;
    NSUInteger minimalPurge = capacity / 10;

    // Defaults

    NSNumber *capacityNumber = [cfg objectForKey:@"capacity"];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && [cfg objectForKey:@"capacity-ipad"])
    {
        NSLog(@"***** WARNING: deprecated config option capacity-ipad, use a predicate instead: -[%@ %@] (line %d)", self, NSStringFromSelector(_cmd), __LINE__);
        capacityNumber = [cfg objectForKey:@"capacity-ipad"];
    }

    NSString *strategyStr = [cfg objectForKey:@"strategy"];
    NSNumber *useCacheDirNumber = [cfg objectForKey:@"useCachesDirectory"];
    NSNumber *minimalPurgeNumber = [cfg objectForKey:@"minimalPurge"];
    NSNumber *expiryPeriodNumber = [cfg objectForKey:@"expiryPeriod"];

    NSArray *predicates = [cfg objectForKey:@"predicates"];

    if (predicates)
    {
        NSDictionary *predicateValues = [self predicateValues];

        for (NSDictionary *predicateDescription in predicates)
        {
            NSString *predicate = [predicateDescription objectForKey:@"predicate"];
            if ( ! predicate)
                continue;

            if ( ! [[NSPredicate predicateWithFormat:predicate] evaluateWithObject:predicateValues])
                continue;

            if ([predicateDescription objectForKey:@"capacity"])
                capacityNumber = [predicateDescription objectForKey:@"capacity"];
            if ([predicateDescription objectForKey:@"strategy"])
                strategyStr = [predicateDescription objectForKey:@"strategy"];
            if ([predicateDescription objectForKey:@"useCachesDirectory"])
                useCacheDirNumber = [predicateDescription objectForKey:@"useCachesDirectory"];
            if ([predicateDescription objectForKey:@"minimalPurge"])
                minimalPurgeNumber = [predicateDescription objectForKey:@"minimalPurge"];
            if ([predicateDescription objectForKey:@"expiryPeriod"])
                expiryPeriodNumber = [predicateDescription objectForKey:@"expiryPeriod"];
        }
    }

    // Check the values

    if (capacityNumber != nil)
    {
        NSInteger value = [capacityNumber intValue];

        // 0 is valid: it means no capacity limit
        if (value >= 0)
        {
            capacity =  value;
            minimalPurge = MAX(1,capacity / 10);
        }
        else
        {
            RMLog(@"illegal value for capacity: %ld", (NSInteger)value);
        }
    }

    if (strategyStr != nil)
    {
        if ([strategyStr caseInsensitiveCompare:@"FIFO"] == NSOrderedSame) strategy = RMCachePurgeStrategyFIFO;
        if ([strategyStr caseInsensitiveCompare:@"LRU"] == NSOrderedSame) strategy = RMCachePurgeStrategyLRU;
    }
    else
    {
        strategyStr = @"FIFO";
    }

    if (useCacheDirNumber != nil)
        useCacheDir = [useCacheDirNumber boolValue];

    if (minimalPurgeNumber != nil && capacity != 0)
    {
        NSUInteger value = [minimalPurgeNumber unsignedIntValue];

        if (value > 0 && value<=capacity)
            minimalPurge = value;
        else
            RMLog(@"minimalPurge must be at least one and at most the cache capacity");
    }

    if (expiryPeriodNumber != nil)
        _expiryPeriod = [expiryPeriodNumber doubleValue];

    RMLog(@"Database cache configuration: {capacity : %ld, strategy : %@, minimalPurge : %ld, expiryPeriod: %.0f, useCacheDir : %@}", (NSUInteger)capacity, strategyStr, (NSUInteger)minimalPurge, _expiryPeriod, useCacheDir ? @"YES" : @"NO");

    RMDatabaseCache *dbCache = [[RMDatabaseCache alloc] initUsingCacheDir:useCacheDir];
    [dbCache setCapacity:capacity];
    [dbCache setPurgeStrategy:strategy];
    [dbCache setMinimalPurge:minimalPurge];
    [dbCache setExpiryPeriod:_expiryPeriod];

    return dbCache;
}

@end
