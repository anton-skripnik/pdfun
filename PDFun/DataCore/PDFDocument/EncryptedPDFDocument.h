//
//  EncryptedPDFDocument.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFDocument.h"

//
//  The class represents encrypted binaries with PDF data in them. Its -open... method
//  prepares a temporary plain PDF for other code to work with.
//

@interface EncryptedPDFDocument : NSObject<PDFDocumentProtocol>

@property (nonatomic, copy, readonly)   NSString*   path;
// The password property must be set before -openWithCompletion: is invoked in order to
// decrypt the document.
@property (nonatomic, copy)             NSString*   password;

@end
