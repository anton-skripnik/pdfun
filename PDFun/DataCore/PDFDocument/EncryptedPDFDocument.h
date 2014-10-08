//
//  EncryptedPDFDocument.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFDocument.h"

@interface EncryptedPDFDocument : NSObject<PDFDocumentProtocol>

@property (nonatomic, copy, readonly)   NSString*   path;

@end
