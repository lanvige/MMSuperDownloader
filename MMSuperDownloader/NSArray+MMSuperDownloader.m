//
//  NSArray+FileManager.m
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/13/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "NSArray+MMSuperDownloader.h"

@implementation NSArray (MMSuperDownloader)

- (BOOL)writeToFile:(NSString *)filename
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];

    return didWriteSuccessfull;
}

+ (NSArray *)readFromFile:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
