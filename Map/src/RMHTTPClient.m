//
//  RMHTTPClient.m
//  MacMapView
//
//  Created by David Bainbridge on 5/6/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "RMHTTPClient.h"
#import "RMHTTPRequestTileOperation.h"
@interface RMHTTPClient ()
@property (nonatomic, strong) NSMutableArray *requestList;
@property (nonatomic, strong) dispatch_queue_t queue;
@end


@implementation RMHTTPClient
- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.operationQueue.maxConcurrentOperationCount = 4;
    [self.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
    _requestList = [[NSMutableArray alloc] init];
    _queue = dispatch_queue_create("route-me.rmhttpclient", DISPATCH_QUEUE_CONCURRENT);
    return self;
}

- (BOOL)containsObject:(id)object
{
    __block BOOL contains;
    dispatch_sync(self.queue, ^{
        contains = [_requestList containsObject:object];
    });
    return contains;
}

- (void)addObject:(id)object
{
    dispatch_barrier_async(_queue, ^{
        [_requestList addObject:object];
    });
}

- (id)fetchAndRemoveLastObject
{
    __block id lastObject;
    dispatch_barrier_sync(_queue, ^{
        lastObject = [_requestList lastObject];
        [_requestList removeObject:lastObject];
    });
    return lastObject;
}

- (void)removeCacheObject:(id)object
{
    dispatch_barrier_async(_queue, ^{
        [_requestList removeObject:object];
    });
    
}

- (void)enqueueHTTPRequestOperation:(RMHTTPRequestTileOperation *)operation {
    if (self.operationQueue.operationCount <= 8)
        [self.operationQueue addOperation:operation];
    else
        [self.requestList addObject:operation];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSOperationQueue *q = object;
    if (q.operationCount <= 8) {
        id lastObject = [self fetchAndRemoveLastObject];
        [self.operationQueue addOperation:lastObject];        
    }
}
@end
