//
//  MCDownloadRequestOperation.m
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/9/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "MMDownloadRequestOperation.h"

@implementation MMDownloadRequestOperation

- (id)initWithRequest:(NSURL *)urlRequest
    downloadKey:(NSString *)downloadKey
    pathPrefix:(NSString *)pathPrefix
{
    self.downloadKey = downloadKey;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlRequest cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];

    // Config the save path;
    NSString *filename = [urlRequest lastPathComponent];

    self = [super initWithRequest:request
                       targetPath:[pathPrefix stringByAppendingPathComponent:filename]
                     shouldResume:YES];

    if (self) {
        __weak __typeof(& *self) weakSelf = self;
        [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
             //
             if (weakSelf.downloadCompleteBlock) {
                 weakSelf.downloadCompleteBlock();
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [super deleteTempFileWithError:nil];
         }];

        [super setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
             weakSelf.totalBytesReadForFile = totalBytesReadForFile;

             // Invoke downloadProgressBlock
             if (weakSelf.downloadProgressBlock) {
                 weakSelf.downloadProgressBlock();
             }
         }];
    }

    return self;
}

- (void)pause
{
    [super pause];
}

- (void)cancel
{
    [super cancel];
}

@end
