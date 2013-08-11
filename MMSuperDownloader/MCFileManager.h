//
//  MCFileManager.h
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/14/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MCFILEMANAGER ((MCFileManager *) [MCFileManager sharedInstance])

@interface MCFileManager : NSObject

+ (id) sharedInstance;

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *libraryPath;

- (BOOL) isFrameInfoExistWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (BOOL) isDownloadCompleteWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (BOOL) addDownloadCompleteFlagFileWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (BOOL) isFileAlreayExistWithName:(NSString *) fileName
    courseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (BOOL) isFileAlreayExistWithUrlString:(NSString *) urlString
    courseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (NSString *) getSavePathPrefixWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (void) deleteCourse:(NSString *) courseId
    error:(void(^) (NSError *))error;
- (void) deleteCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId
    error:(void(^) (NSError * error))error;
- (BOOL) wasDownloadStartWithCourseId:(NSString *) courseId coursewareId:(NSString *) coursewareId;
- (NSString *) getFrameInfoContentWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (long long) getDownloadedSizeWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (void) unZipImgPackageWithCourseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId
    error:(void(^) (NSError *))error;
- (NSString *) getLocalPathWithUrl:(NSString *) url
    courseId:(NSString *) courseId
    coursewareId:(NSString *) coursewareId;
- (void) deleteAllCoursesWithError:(void(^) (NSError *))error;

@end
