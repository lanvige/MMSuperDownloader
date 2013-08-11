//
//  AFHTTPClient+BatchDownload.h
//  MCDownload
//
//  Created by Lanvige Jiang on 5/6/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFHTTPClient (BatchDownload)

- (void)enqueueBatchOfHTTPDownloadRequestOperations:(NSArray *) operations
    wholdProgressBlock:(void(^) (long long wholeDownloadSize)) wholeProgressBlock
    wholeCompletionBlock:(void(^) (NSArray * operations))wholdCompletionBlock;

- (void)cancelBatchOfHTTPDownloadRequestOperationsWithKey:(NSString *) downloadKey;

@end
