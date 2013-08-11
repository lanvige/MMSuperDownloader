//
//  NSURL+Filename.m
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/14/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import "NSURL+Filename.h"

@implementation NSURL (Filename)

- (NSString *)getFilename
{
    NSArray *paths = [[self absoluteString] componentsSeparatedByString:@"?"];
    NSArray *myArray = [(NSString *) paths[0] componentsSeparatedByString : @"/"];
    NSString *fileName = (NSString *) [myArray lastObject];

    return fileName;
}

@end
