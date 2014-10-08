//
//  TemporaryStorageManager.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  Manages everything that's not supposed to persist.
//

@interface TemporaryStorageManager : NSObject

+ (instancetype)sharedManager;

// Issues relatively unique (including timestamps) path within tmp/ directory.
// fileNamePrefix determines the beginning of file name.
- (NSString *)pathForNamePrefix:(NSString *)fileNamePrefix ofType:(NSString *)extension;

@end
