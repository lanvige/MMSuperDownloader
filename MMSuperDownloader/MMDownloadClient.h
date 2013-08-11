//
//  MCDownloadClient.h
//  MCampusTeacher
//
//  Created by Lanvige Jiang on 5/15/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface MMDownloadClient : AFHTTPClient

+ (id)sharedInstance;

@end
