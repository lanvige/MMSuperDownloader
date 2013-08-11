//
//  MCDownloadManager.h
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/9/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDownloadStatus.h"

#define MCDOWNLOADMANAGER ((MCDownloadManager *) [MCDownloadManager sharedInstance])

@interface MCDownloadManager : NSObject

+ (id) sharedInstance;

- (MCDownloadStatus) getDownloadStatusWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;

- (long long) getDownloadedSizeWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;

// TODO: need to add failure check.
- (void) downloadWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;

- (NSArray *) getFrameInfoWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;

- (void) pauseDownloadWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;

// - (void)downloadFrameInfoWithCourseId:(NSString *)courseId
//    coursewareId:(NSString *)coursewareId
//    success:(void (^)(void))success
//    failure:(void (^)(NSError *error))failure;
//
// - (BOOL)storeFrameInfo:(NSArray *)frame
//    withCourseId:(NSString *)courseId
//    coursewareId:(NSString *)coursewareId;
// - (NSArray *)getFrameInfoWithCourseId:(NSString *)courseId
//    coursewareId:(NSString *)coursewareId;

@end
