//
//  MCDownloadManager.m
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/9/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "MCDownloadManager.h"
#import "MCKFrameInfo.h"
#import "MCDownloadRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFHTTPClient+BatchDownload.h"
#import "MCDownloadClient.h"
#import "MCFileManager.h"

@implementation MCDownloadManager

+ (id)sharedInstance
{
    static MCDownloadManager *_sharedClient = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      _sharedClient = [[MCDownloadManager alloc] init];
                  });

    return _sharedClient;
}

- (MCDownloadStatus)getDownloadStatusWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    if ([MCFILEMANAGER isDownloadCompleteWithCourseId:courseId coursewareId:coursewareId]) {
        return MCDownloadFinished;
    }

    if ([MCFILEMANAGER wasDownloadStartWithCourseId:courseId coursewareId:coursewareId]) {
        return MCDownloadPause;
    }

    // 都没有，表示准备完成
    return MCDownloadReady;
}

- (void)downloadWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    // check frameinfo file.
    [self downloadFrameInfoWithCourseId:courseId
                           coursewareId:coursewareId
                                success:^{
         // get the frameinfo list;
         NSArray *arr = [self getFrameInfoWithCourseId:courseId coursewareId:coursewareId];
         // build download resource list from frameinfo list;
         NSArray *resources = [self buildDownloadResourceListWithFrameInfoList:arr];
         // download the list;
         [self downloadResources:resources
                    withCourseId:courseId
                    coursewareId:coursewareId];
     } failure:^(NSError *error) {
         //
     }];
}

// Add download resource to queue
- (void)downloadResources:(NSArray *)resources
    withCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    if (resources.count <= 0) {
        // 没有可下内容时，要回调Manager，更改状态。
        return;
    }

    // 加到一个队列，然后通知下载器开始去取队列，下载。
    NSMutableArray *operations = [[NSMutableArray alloc] init];

    for (NSString *resourceUrl in resources) {
        if ([MCFILEMANAGER isFileAlreayExistWithUrlString:resourceUrl
                                                 courseId:courseId
                                             coursewareId:coursewareId]) {
            continue;
        }

        NSString *pathPrefix = [MCFILEMANAGER getSavePathPrefixWithCourseId:courseId coursewareId:coursewareId];
        NSString *key = [NSString stringWithFormat:@"dl_key_c_%@_cw_%@", courseId, coursewareId];
        MCDownloadRequestOperation *operation = [[MCDownloadRequestOperation alloc] initWithRequest:[NSURL URLWithString:resourceUrl] downloadKey:key pathPrefix:pathPrefix];

        [operations addObject:operation];
    }

    MCDownloadClient *downloadClient = [MCDownloadClient sharedInstance];

    [downloadClient enqueueBatchOfHTTPDownloadRequestOperations:operations
                                             wholdProgressBlock:^(long long wholeDownloadSize) {
         MCLogInfo(@"------wholeDownloadSize-------f-%lld", wholeDownloadSize);
         // 取整体下载进度。
         NSString *downloadingNotificationName = [NSString stringWithFormat:@"c_%@_cw%@_downloading", courseId, coursewareId];
         NSDictionary *dict = @{ @"downloadKey" : downloadingNotificationName, @"downloadProgress" : @(wholeDownloadSize) };
         NSNotification *nnf = [NSNotification notificationWithName:downloadingNotificationName object:dict];
         [[NSNotificationCenter defaultCenter] postNotification:nnf];
     } wholeCompletionBlock:^(NSArray *operations) {
         MCLogInfo(@"------wholecompletionBlock-------");
         [MCFILEMANAGER addDownloadCompleteFlagFileWithCourseId:courseId coursewareId:coursewareId];

         NSString *downloadedNotificationName = [NSString stringWithFormat:@"c_%@_cw%@_downloaded", courseId, coursewareId];
         NSNotification *nnfed = [NSNotification notificationWithName:downloadedNotificationName object:nil];
         [[NSNotificationCenter defaultCenter] postNotification:nnfed];
     }];
}


- (void)pauseDownloadWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *key = [NSString stringWithFormat:@"dl_key_c_%@_cw_%@", courseId, coursewareId];

    [[MCDownloadClient sharedInstance] cancelBatchOfHTTPDownloadRequestOperationsWithKey:key];
}

- (void)downloadComplete
{
//    [self unzipFileAtPath];
//    self.downloadState = MCDownloadFinished;
}

- (void)downloadFrameInfoWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
    success:(void (^)(void))success
    failure:(void (^)(NSError *error))failure
{
    // check frameinfo file.
    if (![MCFILEMANAGER isFrameInfoExistWithCourseId:courseId
                                        coursewareId:coursewareId]) {
        MCKCoursewareDataProvider *coursewareDataProvider = [[MCKCoursewareDataProvider alloc] init];
        [coursewareDataProvider getCoursewareFrameInfoContentWithCoursewareId:coursewareId
                                                                      success:^(id responseObject) {
             MCDownloadManager *downloadManager = [[MCDownloadManager alloc] init];
             [downloadManager storeFrameInfo:responseObject
                                withCourseId:courseId
                                coursewareId:coursewareId];

             if (success) {
                 success();
             }
         } failure:^(NSError *error) {
             if (failure) {
                 failure(error);
             }
         }];
    } else {
        if (success) {
            success();
        }
    }
}

- (NSArray *)buildDownloadResourceListWithFrameInfoList:(NSArray *)frameInfoList
{
    NSMutableArray *resourceList = [[NSMutableArray alloc] init];

    for (MCKFrameInfo *frameInfo in frameInfoList) {
        if ([frameInfo.resourceType isEqualToString:@"ZIP"]) {
            // If exist
            if (![resourceList containsObject:frameInfo.resourceUrl]) {
                [resourceList addObject:frameInfo.resourceUrl];
            }
        } else if ([frameInfo.resourceType isEqualToString:@"MP3"]) {
            if (![resourceList containsObject:frameInfo.audioUrl]) {
                [resourceList addObject:frameInfo.audioUrl];
            }
        } else if ([frameInfo.resourceType isEqualToString:@"MP3+JPG"]) {
            if (![resourceList containsObject:frameInfo.audioUrl]) {
                [resourceList addObject:frameInfo.audioUrl];
            }
        } else if ([frameInfo.resourceType isEqualToString:@"MP4"]) {
            if (![resourceList containsObject:frameInfo.resourceUrl]) {
                [resourceList addObject:frameInfo.resourceUrl];
            }
        }
    }

    return resourceList;
}

- (BOOL)storeFrameInfo:(NSArray *)frame
    withCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    // Create the folder
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *targetForder = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@", courseId, coursewareId]];

    [[NSFileManager defaultManager] createDirectoryAtPath:targetForder withIntermediateDirectories:YES attributes:nil error:nil];

    // Convert the json
    __autoreleasing NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:frame options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    // Save file
    NSString *filePath = [targetForder stringByAppendingPathComponent:@"frameInfo.json"];
    BOOL didWriteSuccessfull = [jsonString writeToFile:filePath
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    return didWriteSuccessfull;
}

- (NSArray *)getFrameInfoWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *content = [MCFILEMANAGER getFrameInfoContentWithCourseId:courseId coursewareId:coursewareId];
    NSData *JSONData = [content dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];

    // Parse json array
    NSMutableArray *array;

    if ([jsonData isKindOfClass:[NSArray class]]) {
        NSArray *jsonArray = (NSArray *) jsonData;
        array = [NSMutableArray arrayWithCapacity:jsonArray.count];

        for (NSDictionary *attributes in jsonArray) {
            MCKFrameInfo *frameInfo = [[MCKFrameInfo alloc] init];
            [frameInfo unpackDictionary:attributes];
            [array addObject:frameInfo];
        }
    }

    return array;
}

- (long long)getDownloadedSizeWithCourseId:(NSString *)courseId coursewareId:(NSString *)coursewareId
{
    return [MCFILEMANAGER getDownloadedSizeWithCourseId:courseId
                                           coursewareId:coursewareId];
}

@end
