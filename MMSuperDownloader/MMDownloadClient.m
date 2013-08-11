//
//  MCDownloadClient.m
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/15/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "MMDownloadClient.h"
#import "MMDownloadRequestOperation.h"

@implementation MMDownloadClient

+ (id)sharedInstance
{
    static MMDownloadClient *_sharedClient = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedClient = [[MMDownloadClient alloc] init];
    });

    return _sharedClient;
}

- (id)init
{
    if (self = [super init]) {
        [self registerHTTPOperationClass:[MMDownloadRequestOperation class]];
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }

    return self;
}

@end
