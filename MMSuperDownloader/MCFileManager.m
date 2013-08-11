//
//  MCFileManager.m
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/14/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "MCFileManager.h"
#import "NSURL+Filename.h"
#import "SSZipArchive.h"

@implementation MCFileManager

+ (id)sharedInstance
{
    static MCFileManager *_sharedClient = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      _sharedClient = [[MCFileManager alloc] init];
                  });

    return _sharedClient;
}

- (id)init
{
    self = [super init];

    if (self) {
        self.fileManager = [NSFileManager defaultManager];
        self.libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }

    return self;
}

- (BOOL)isDownloadCompleteWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    // 完成标志存在，表示已下完。
    NSString *dldFilePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/completed.mc", courseId, coursewareId]];
    BOOL isComplete = [self.fileManager fileExistsAtPath:dldFilePath];

    return isComplete;
}

- (BOOL)isFileAlreayExistWithName:(NSString *)fileName
    courseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    // 完成标志存在，表示已下完。
    NSString *dldFilePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/res/%@", courseId, coursewareId, fileName]];
    BOOL isComplete = [self.fileManager fileExistsAtPath:dldFilePath];

    return isComplete;
}

- (BOOL)isFileAlreayExistWithUrlString:(NSString *)urlString
    courseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSURL *url = [NSURL URLWithString:urlString];

    return [self isFileAlreayExistWithName:[url getFilename]
                                  courseId:courseId
                              coursewareId:coursewareId];
}

- (long long)getDownloadedSizeWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *targetPath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/res", courseId, coursewareId]];

    return [self fileSizeAtPath:targetPath];
}

- (BOOL)addDownloadCompleteFlagFileWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *jsonString = @"1";

    // Convert the json
    __autoreleasing NSError *error = nil;

    // Save file
    NSString *targetForder = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@", courseId, coursewareId]];
    NSString *filePath = [targetForder stringByAppendingPathComponent:@"completed.mc"];
    BOOL didWriteSuccessfull = [jsonString writeToFile:filePath
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];

    return didWriteSuccessfull;
}

// Get download prefix.
- (NSString *)getSavePathPrefixWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *targetPath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/res", courseId, coursewareId]];

    [self.fileManager createDirectoryAtPath:targetPath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];

    return targetPath;
}

- (void)deleteFileWithPath:(NSString *)path
    error:(void (^)(NSError *))error
{
    BOOL fileExists = [self.fileManager fileExistsAtPath:path];

    if (fileExists) {
        NSError *err = nil;
        [self.fileManager removeItemAtPath:path error:&err];

        if (err && error) {
            error(err);
        }
    }
}

- (void)deleteCourse:(NSString *)courseId
    error:(void (^)(NSError *))error
{

    NSString *targetPath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@", courseId]];

    [self deleteFileWithPath:targetPath error:error];
}

- (void)deleteCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
    error:(void (^)(NSError *error))error
{
    NSString *targetPath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@", courseId, coursewareId]];

    [self deleteFileWithPath:targetPath error:error];
}

- (BOOL)isResourceFileExistWithName:(NSString *)fileName
    CourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *filePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/%@", courseId, coursewareId, fileName]];

    BOOL fileExists = [self.fileManager fileExistsAtPath:filePath];

    return fileExists;
}

- (BOOL)isFrameInfoExistWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    NSString *filePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/frameInfo.json", courseId, coursewareId]];

    BOOL fileExists = [self.fileManager fileExistsAtPath:filePath];

    return fileExists;
}

- (BOOL)isFrameInfoFileExistWithCourseId:(NSString *)courseId coursewareId:(NSString *)coursewareId
{
    NSString *filePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/frameInfo.json", courseId, coursewareId]];

    BOOL fileExists = [self.fileManager fileExistsAtPath:filePath];

    return fileExists;
}

- (BOOL)wasDownloadStartWithCourseId:(NSString *)courseId coursewareId:(NSString *)coursewareId
{
    // 目录存在，表示已经开始下载过了。
    NSString *filePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/res", courseId, coursewareId]];
    BOOL fileExists = [self.fileManager fileExistsAtPath:filePath];

    return fileExists;
}

- (NSString *)getFrameInfoContentWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    // Build file path
    NSString *filePath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/frameInfo.json", courseId, coursewareId]];

    // Get string
    NSString *contentString = [[NSString alloc] initWithContentsOfFile:filePath
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];

    return contentString;
}

- (void)unZipImgPackageWithCourseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
    error:(void (^)(NSError *))error
{
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/pic.zip", [self getSavePathPrefixWithCourseId:courseId coursewareId:coursewareId]];

    if (![SSZipArchive unzipFileAtPath:zipFilePath toDestination:[self getSavePathPrefixWithCourseId:courseId coursewareId:coursewareId]]) {
    }

    [self deleteFileWithPath:zipFilePath error:error];
}

- (long long)fileSizeAtPath:(NSString *)folderPath
{
    long long size = 0;
    NSArray *array = [self.fileManager contentsOfDirectoryAtPath:folderPath error:nil];

    for (int i = 0; i < [array count]; i++) {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:[array objectAtIndex:i]];

        BOOL isDir;

        if ( !([self.fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) ) {
            NSDictionary *fileAttributeDic = [self.fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        } else {
            [self fileSizeAtPath:fullPath];
        }
    }

    return size;
}


- (NSString *)getLocalPathWithUrl:(NSString *)url
    courseId:(NSString *)courseId
    coursewareId:(NSString *)coursewareId
{
    if ([url isEqual:[NSNull null]]) {
        return @"";
    }

    NSString *targetPath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware/%@/%@/res", courseId, coursewareId]];

    [self.fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:nil];

    NSArray *myArray = [url componentsSeparatedByString:@"/"];
    NSString *fileName = (NSString *) [myArray lastObject];

    return [NSString stringWithFormat:@"%@/%@", targetPath, fileName];
}


- (void)deleteAllCoursesWithError:(void (^)(NSError *))error
{
    NSString *targetPath = [self.libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Courseware"]];

    [self deleteFileWithPath:targetPath error:error];
}

@end
