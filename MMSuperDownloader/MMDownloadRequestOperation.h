//
//  MCDownloadRequestOperation.h
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/9/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"

@interface MMDownloadRequestOperation : AFDownloadRequestOperation

@property (nonatomic, strong) NSString *downloadKey;
@property (nonatomic, assign) long long totalBytesReadForFile;

// http://stackoverflow.com/questions/3935574/can-i-use-objective-c-blocks-as-properties
typedef void (^MCDownloadProgressBlock)();
@property (nonatomic, copy) MCDownloadProgressBlock downloadProgressBlock;
typedef void (^MCDownloadCompleteBlock)();
@property(readwrite, copy) MCDownloadCompleteBlock downloadCompleteBlock;

- (id) initWithRequest:(NSURL *) urlRequest downloadKey:(NSString *) downloadKey pathPrefix:(NSString *) pathPrefix;
- (void) pause;

@end
