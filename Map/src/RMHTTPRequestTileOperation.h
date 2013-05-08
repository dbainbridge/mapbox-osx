//
//  RMHTTPRequestTileOperation.h
//  MacMapView
//
//  Created by David Bainbridge on 5/8/13.
//  Copyright (c) 2013 David Bainbridge. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "RMTile.h"

@interface RMHTTPRequestTileOperation : AFHTTPRequestOperation
@property (nonatomic, assign) RMTile tile;
- (id)initWithRequest:(NSURLRequest *)urlRequest tile:(RMTile)aTile;
@end
