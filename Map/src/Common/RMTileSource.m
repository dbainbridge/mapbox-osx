//
//  RMTileSource.m
//  MacMapView
//
//  Created by David Bainbridge on 5/3/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "RMTileSource.h"

@interface RMTileSource()

@end

@implementation RMTileSource

- (id)init
{
    self = [super init];
    if (self) {
        _cacheable = YES;
        _opaque = YES;
    }
    return self;
}

- (NSImage *)imageForTile:(RMTile)tile inCache:(RMTileCacheBase *)tileCache withBlock:(void (^)(NSImage *))imageBlock
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

@end
