//
//  TemporaryStorageManager.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "TemporaryStorageManager.h"

@implementation TemporaryStorageManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static TemporaryStorageManager* staticManager = nil;
    dispatch_once(&onceToken, ^
    {
        staticManager = [[self alloc] init];
    });
    
    return staticManager;
}

- (NSString *)pathForNamePrefix:(NSString *)fileNamePrefix ofType:(NSString *)extension
{
    if ([fileNamePrefix length] == 0 && [extension length] == 0)
    {
        return nil;
    }

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss_SSS"];
    NSString* nowString = [formatter stringFromDate:[NSDate date]];
    
    NSString* fileName = [[NSString stringWithFormat:@"%@ %@", fileNamePrefix, nowString] stringByAppendingPathExtension:extension];
    NSString* tempDirectoryPath = NSTemporaryDirectory();
    
    return [tempDirectoryPath stringByAppendingPathComponent:fileName];
}

@end
