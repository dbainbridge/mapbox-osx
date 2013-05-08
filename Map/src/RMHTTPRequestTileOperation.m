//
//  RMHTTPRequestTileOperation.m
//  MacMapView
//
//  Created by David Bainbridge on 5/8/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "RMHTTPRequestTileOperation.h"

@implementation RMHTTPRequestTileOperation
- (id)initWithRequest:(NSURLRequest *)urlRequest tile:(RMTile)aTile
{
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }
    _tile = aTile;
    
    return self;
}

@end
