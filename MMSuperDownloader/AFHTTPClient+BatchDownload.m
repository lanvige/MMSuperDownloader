//
//  AFHTTPClient+BatchDownload.m
//  MCDownload
//
//  Created by Lanvige Jiang on 5/6/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "AFHTTPClient+BatchDownload.h"
#import "MMDownloadRequestOperation.h"

@implementation AFHTTPClient (BatchDownload)

- (void)enqueueBatchOfHTTPDownloadRequestOperations:(NSArray *)operations
    wholdProgressBlock:(void (^)(long long wholeDownloadSize))wholeProgressBlock
    wholeCompletionBlock:(void (^)(NSArray *operations))wholeCompletionBlock
{
    __block dispatch_group_t dispatchGroup = dispatch_group_create();
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
                if (wholeCompletionBlock) {
                    wholeCompletionBlock(operations);
                }
            });
#if !OS_OBJECT_USE_OBJC
          dispatch_release(dispatchGroup);
#endif
      }];

    for (MMDownloadRequestOperation *operation in operations) {
        // http://stackoverflow.com/questions/10892361/generic-typeof-for-weak-self-references
        __weak __typeof(& *operation) weakOperation = operation;

        // 每个operation的completionBlock被改为如下。
        // 也就是每当一个文件下载完之后会被执行一次。
        operation.downloadProgressBlock = ^(long long totalBytesReadForFile){
            __strong __typeof(& *weakOperation) strongOperation = weakOperation;
            dispatch_queue_t queue = strongOperation.progressiveDownloadCallbackQueue ? : dispatch_get_main_queue();
            dispatch_group_async(dispatchGroup, queue, ^{
                long long downloadedContentLength = 0;

                for (MMDownloadRequestOperation *op in operations) {
                 downloadedContentLength += op.totalBytesReadForFile;
                }

                if (wholeProgressBlock) {
                 wholeProgressBlock(downloadedContentLength);
                }
            });
        };

        operation.downloadCompleteBlock = ^{
            __strong __typeof(& *weakOperation) strongOperation = weakOperation;
            dispatch_queue_t queue = strongOperation.successCallbackQueue ? : dispatch_get_main_queue();
            dispatch_group_async(dispatchGroup, queue, ^{
                                     dispatch_group_leave(dispatchGroup);
                                 });
        };

        dispatch_group_enter(dispatchGroup);
        [batchedOperation addDependency:operation];
    }

    [self.operationQueue addOperations:operations waitUntilFinished:NO];
    [self.operationQueue addOperation:batchedOperation];
}

- (void)cancelBatchOfHTTPDownloadRequestOperationsWithKey:(NSString *)downloadKey
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[MMDownloadRequestOperation class]]) {
            continue;
        }

        MMDownloadRequestOperation *op = (MMDownloadRequestOperation *) operation;

        if ([downloadKey isEqualToString:op.downloadKey]) {
            [op pause];
        }
    }
}

@end
