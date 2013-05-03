//
//  RMMapTiledLayerView.m
//  MapView
//
//  Created by David Bainbridge on 2/17/13.
//
//

#import "RMMapTiledLayerView.h"

#import "RMMapView.h"
#import "RMTileSource.h"
#import "RMTileImage.h"
#import "RMTileCacheMulti.h"
#import "RMMBTilesSource.h"
#import "RMDBMapSource.h"
#import "RMAbstractWebMapSource.h"
#import "RMDatabaseCache.h"

#define IS_VALID_TILE_IMAGE(image) (image != nil && [image isKindOfClass:[NSImage class]])

@interface FastCATiledLayer : CATiledLayer
@end

@implementation FastCATiledLayer
+(CFTimeInterval)fadeDuration {
    return 0.0;
}
@end

@interface RMMapTiledLayerView ()
{

}
@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, strong) dispatch_queue_t queue;
@end


@implementation RMMapTiledLayerView
{
    RMMapView *_mapView;
    id <RMTileSource> _tileSource;
}

- (BOOL)isFlipped
{
    return YES;
}

@synthesize useSnapshotRenderer = _useSnapshotRenderer;
@synthesize tileSource = _tileSource;

+ (Class)layerClass
{
    return [FastCATiledLayer class];
}

- (CATiledLayer *)tiledLayer
{
    return (CATiledLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame mapView:(RMMapView *)aMapView forTileSource:(id <RMTileSource>)aTileSource
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
        // TODO: FIX ME
//    self.opaque = NO;
    
    _mapView = aMapView;
    _tileSource = aTileSource;
    
    //dbainbridge
    self.layer = [FastCATiledLayer layer];
    self.wantsLayer = YES;
    self.layer.delegate = self;
    
    self.useSnapshotRenderer = NO;
    
    CATiledLayer *tiledLayer = [self tiledLayer];
    size_t levelsOf2xMagnification = _mapView.tileSourcesMaxZoom;
    if (_mapView.adjustTilesForRetinaDisplay && _mapView.screenScale > 1.0) levelsOf2xMagnification += 1;
    tiledLayer.levelsOfDetail = levelsOf2xMagnification;
    tiledLayer.levelsOfDetailBias = levelsOf2xMagnification;
    [tiledLayer setNeedsDisplay];
    
//    [self setAutoresizesSubviews:YES];
//    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    _cache = [[NSMutableDictionary alloc] init];
    _queue = dispatch_queue_create("com.route-me.cachequeuedictionary", DISPATCH_QUEUE_CONCURRENT);

    return self;
}

- (void)dealloc
{
    [_tileSource cancelAllDownloads];
    self.layer.contents = nil;
    _mapView = nil;
}

/*
- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint p = [theEvent locationInWindow];
    [self scrollRectToVisible:NSMakeRect(p.x - self.visibleRect.origin.x, p.y - self.visibleRect.origin.y, self.visibleRect.size.width, self.visibleRect.size.height)];
    [self autoscroll:theEvent];
}
*/


- (void)didMoveToWindow
{
//TODO: FIX ME 
//    self.contentScaleFactor = 1.0f;
}

- (void)renderSnapshotInContext:(CGContextRef)context
{
    CGRect rect   = CGContextGetClipBoundingBox(context);
    CGRect bounds = self.bounds;
    
    //    short zoom    = log2(bounds.size.width / rect.size.width);
    short zoom    = _mapView.zoom;
    
    //  what is with this???  if I don't do this the gesture zoom is messed up
    if (zoom > 1.0)
        zoom++;
    //    NSLog(@"drawLayer: {{%f,%f},{%f,%f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //    NSLog(@"drawLayer Zoom: %d", zoom);
    
    
    zoom = (short)ceilf(_mapView.adjustedZoomForRetinaDisplay);
    CGFloat rectSize = bounds.size.width / powf(2.0, (float)zoom);
    
    int x1 = floor(rect.origin.x / rectSize),
    x2 = floor((rect.origin.x + rect.size.width) / rectSize),
    y1 = floor(fabs(rect.origin.y / rectSize)),
    y2 = floor(fabs((rect.origin.y + rect.size.height) / rectSize));
    
    //        NSLog(@"Tiles from x1:%d, y1:%d to x2:%d, y2:%d @ zoom %d", x1, y1, x2, y2, zoom);
    
    if (zoom >= _tileSource.minZoom && zoom <= _tileSource.maxZoom)
    {
        UIGraphicsPushContext(context);
        
        for (int x=x1; x<=x2; ++x)
        {
            for (int y=y1; y<=y2; ++y)
            {
                NSImage *tileImage = [_tileSource imageForTile:RMTileMake(x, y, zoom) inCache:[_mapView tileCache] withBlock:nil];
                
                if (IS_VALID_TILE_IMAGE(tileImage))
                    [tileImage drawInRect:CGRectMake(x * rectSize, y * rectSize, rectSize, rectSize)];
            }
        }
        
        UIGraphicsPopContext();
    }
    
}

- (NSImage *)debugTileWithImage:(NSImage *)tileImage tile:(RMTile)tile
{
    NSImage *newTile = [NSImage imageWithSize:tileImage.size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        CGContextRef debugContext = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect debugRect = CGRectMake(0, 0, tileImage.size.width, tileImage.size.height);
        
        [tileImage drawInRect:debugRect];
        
        NSFont *font = [NSFont systemFontOfSize:32.0];
        
        CGContextSetStrokeColorWithColor(debugContext, [NSColor whiteColor].CGColor);
        CGContextSetLineWidth(debugContext, 2.0);
        CGContextSetShadowWithColor(debugContext, CGSizeMake(0.0, 0.0), 5.0, [NSColor blackColor].CGColor);
        
        CGContextStrokeRect(debugContext, debugRect);
        
        CGContextSetFillColorWithColor(debugContext, [NSColor whiteColor].CGColor);
        
        NSString *debugString = [NSString stringWithFormat:@"Zoom %d", tile.zoom];
        CGSize debugSize1 = [debugString sizeWithFont:font];
        [debugString drawInRect:CGRectMake(5.0, 5.0, debugSize1.width, debugSize1.height) withFont:font];
        
        debugString = [NSString stringWithFormat:@"(%d, %d)", tile.x, tile.y];
        CGSize debugSize2 = [debugString sizeWithFont:font];
        [debugString drawInRect:CGRectMake(5.0, 5.0 + debugSize1.height + 5.0, debugSize2.width, debugSize2.height) withFont:font];
        
        
        return YES;
        
    }];
    
    return newTile;
}

- (NSImage *)createMissingTileImageForTile:(RMTile)tile
{
    NSImage *tileImage;
    
    if (_mapView.missingTilesDepth == 0)
    {
        tileImage = [RMTileImage errorTile];
    }
    else
    {
        NSUInteger currentTileDepth = 1;
        NSUInteger currentZoom = tile.zoom - currentTileDepth;
        
        // tries to return lower zoom level tiles if a tile cannot be found
        while ( !tileImage && currentZoom >= _tileSource.minZoom && currentTileDepth <= _mapView.missingTilesDepth)
        {
            float nextX = tile.x / powf(2.0, (float)currentTileDepth),
            nextY = tile.y / powf(2.0, (float)currentTileDepth);
            float nextTileX = floor(nextX),
            nextTileY = floor(nextY);
            
            tileImage = [_tileSource imageForTile:RMTileMake((int)nextTileX, (int)nextTileY, currentZoom) inCache:[_mapView tileCache] withBlock:nil];
            
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

- (NSImage *)cropTileImage:(NSImage *)tileImage withRect:(CGRect)rect tile:(RMTile)tile
{
    // Crop the image
    float xCrop = (floor(rect.origin.x / rect.size.width) / 2.0) - tile.x;
    float yCrop = (floor(rect.origin.y / rect.size.height) / 2.0) - tile.y;
    
    CGRect cropBounds = CGRectMake(tileImage.size.width * xCrop,
                                   tileImage.size.height * yCrop,
                                   tileImage.size.width * 0.5,
                                   tileImage.size.height * 0.5);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([tileImage CGImage], cropBounds);
    tileImage = [NSImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return tileImage;
}

- (void)drawTileImage:(NSImage *)tileImage inContext:(CGContextRef)context rect:(CGRect)rect tile:(RMTile)tile
{
    if (!IS_VALID_TILE_IMAGE(tileImage)) {
        NSLog(@"Invalid image for {%d,%d} @ %d", tile.x, tile.y, tile.zoom);
        return;
    }

    if (_mapView.adjustTilesForRetinaDisplay && _mapView.screenScale > 1.0)
    {
        tileImage = [self cropTileImage:tileImage withRect:rect tile:tile];
    }
    
    NSGraphicsContext *nsGraphicsContext;
    nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context
                                                                   flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsGraphicsContext];
   
#pragma warn Figure out where we need to flip this NSImage/context so we do not have to flip again
    NSImage *flippedImage = [NSImage imageWithSize:tileImage.size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        CGRect debugRect = CGRectMake(0, 0, tileImage.size.width, tileImage.size.height);
        [tileImage drawInRect:debugRect];
        return YES;
    }];
    
    if (_mapView.debugTiles)
    {
        NSImage *debugTile = [self debugTileWithImage:flippedImage tile:tile];
        [debugTile drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.5];
    } else {
        [flippedImage drawInRect:rect];
        
    }
    [NSGraphicsContext restoreGraphicsState];
    
}


- (id)cacheObjectForKey:(id)key
{
    __block id obj;
    dispatch_sync(_queue, ^{
        obj = [_cache objectForKey:key];
    });
    return obj;
}

- (void)setCacheObject:(id)obj forKey:(id)key
{
    dispatch_barrier_async(_queue, ^{
        [_cache setObject:obj forKey:key];
    });
}

- (void)removeCacheObjectForKey:(id)key
{
    dispatch_barrier_async(_queue, ^{
        [_cache removeObjectForKey:key];
    });
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if (self.useSnapshotRenderer)
        return [self renderSnapshotInContext:context];
    
    CGRect rect   = CGContextGetClipBoundingBox(context);
    //    short zoom    = log2(bounds.size.width / rect.size.width);
    short zoom    = _mapView.zoom;
    
    //  what is with this???  if I don't do this the gesture zoom is messed up
    if (zoom > 1.0)
        zoom++;
    //    NSLog(@"drawLayer: {{%f,%f},{%f,%f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //    NSLog(@"drawLayer Zoom: %d", zoom);
    
    int x = floor(rect.origin.x / rect.size.width),
    y = floor(fabs(rect.origin.y / rect.size.height));
    
    if (_mapView.adjustTilesForRetinaDisplay && _mapView.screenScale > 1.0)
    {
        zoom--;
        x >>= 1;
        y >>= 1;
    }
    
    RMTile currentTile = RMTileMake(x, y, zoom);
    
    //        NSLog(@"Tile @ x:%d, y:%d, zoom:%d", x, y, zoom);
    
    
    NSImage *tileImage = nil;
    
    if ((zoom >= _tileSource.minZoom) && (zoom <= _tileSource.maxZoom))
    {
        RMDatabaseCache *databaseCache = _mapView.tileCache.databaseCache;
        
        if (![_tileSource isKindOfClass:[RMAbstractWebMapSource class]] || ! databaseCache || ! databaseCache.capacity)
        {
            // for non-web tiles, query the source directly since trivial blocking
            //
            tileImage = [_tileSource imageForTile:currentTile inCache:[_mapView tileCache] withBlock:nil];
            if (!tileImage)
            {
                tileImage = [self createMissingTileImageForTile:currentTile];
            }
            [self drawTileImage:tileImage inContext:context rect:rect tile:currentTile];
        }
        else
        {
            // For non-local cacheable tiles, check if tile exists in cache already
            
            if (_tileSource.isCacheable) {
                
                tileImage = [[_mapView tileCache] cachedImage:currentTile withCacheKey:[_tileSource uniqueTilecacheKey]];
                
                NSNumber *tileCacheHash = RMTileCacheHash(currentTile);
                if (!tileImage) {
                    if ([self cacheObjectForKey:tileCacheHash]) {
                        return;
                    }
                    else {
                        [self setCacheObject:@"1" forKey:tileCacheHash];
                    }
                    
                    tileImage = [_tileSource imageForTile:currentTile inCache:[_mapView tileCache] withBlock:^(NSImage *newImage) {
                        if (!newImage) {
                            newImage = [self createMissingTileImageForTile:currentTile];
                        }
                        [self removeCacheObjectForKey:tileCacheHash];
                        [self.layer setNeedsDisplayInRect:rect];
 
                    }];
                    
                    if (!tileImage) {
                        tileImage = [self createMissingTileImageForTile:currentTile];
                        if (tileImage)
                            [self drawTileImage:tileImage inContext:context rect:rect tile:currentTile];
                    }

                }
                else {
                    [self drawTileImage:tileImage inContext:context rect:rect tile:currentTile];
                }
           }
        }
    }
    else {
        tileImage = [self createMissingTileImageForTile:currentTile];        
        [self drawTileImage:tileImage inContext:context rect:rect tile:currentTile];
    }
    
    
    
}
@end
