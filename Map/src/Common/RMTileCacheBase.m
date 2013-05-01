//
//  RMTileCacheBase.m
//  MacMapView
//
//  Created by David Bainbridge on 4/30/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "RMTileCacheBase.h"

@implementation RMTileCacheBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        _repondsTo.addImageForTileWithCacheKey = [self respondsToSelector:@selector(addImage:forTile:withCacheKey:)];
        _repondsTo.addImageForTileWithDataWithCacheKey = [self respondsToSelector:@selector(addImage:forTile:withData:withCacheKey:)];
    }
    return self;
}

- (void)removeAllCachedImages
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
    
}

- (void)removeAllCachedImagesForCacheKey:(NSString *)cacheKey
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
    
}

- (UIImage *)cachedImage:(RMTile)tile withCacheKey:(NSString *)cacheKey
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
}

- (void)addImage:(UIImage *)image forTile:(RMTile)tile withCacheKey:(NSString *)cacheKey
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];    
}

- (void)addImage:(UIImage *)image forTile:(RMTile)tile withData:(NSData *)tileData withCacheKey:(NSString *)cacheKey
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]]
                                   reason:[NSString stringWithFormat:@"%s: invoked on %@. Override this method when instantiating an abstract class.", __PRETTY_FUNCTION__, [self class]]
                                 userInfo:nil];    
}


@end
