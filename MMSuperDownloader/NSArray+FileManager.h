//
//  NSArray+FileManager.h
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/13/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FileManager)

- (BOOL)writeToFile:(NSString *) filename;
+ (NSArray *)readFromFile:(NSString *) filename;

@end
