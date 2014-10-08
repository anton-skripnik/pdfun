//
//  NSFileManager+Utils.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "NSFileManager+Utils.h"

@implementation NSFileManager (Utils)

- (BOOL)moveItemAtPath:(NSString *)srcPath possiblyReplacingItemAtPath:(NSString *)dstPath error:(NSError *__autoreleasing *)error
{
    if ([self fileExistsAtPath:dstPath])
    {
        if (![self removeItemAtPath:dstPath error:error])
        {
            return NO;
        }
    }
    
    return [self moveItemAtPath:srcPath toPath:dstPath error:error];
}

@end
