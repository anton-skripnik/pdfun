//
//  NSFileManager+Utils.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Utils)

// Moves a file, deleting a file at destination if one existed.
- (BOOL)moveItemAtPath:(NSString *)srcPath possiblyReplacingItemAtPath:(NSString *)dstPath error:(NSError *__autoreleasing *)error;

@end
