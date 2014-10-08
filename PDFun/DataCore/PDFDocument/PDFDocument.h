//
//  PDFDocument.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#ifndef PDFun_PDFDocument_h
#define PDFun_PDFDocument_h

#import <CoreGraphics/CoreGraphics.h>

// The type of block to be invoked when a document opening is done.
typedef void(^PDFDocumentOpenCompletionBlock)(BOOL succeeded);

//
//  The app handles different types of PDF: plain PDFs and binaries that encapsulate encrypted PDF data along
//  with some public encryption-related info. Concrete classes to represent those types conform to this protocol.
//
@protocol PDFDocumentProtocol <NSObject>

@property (nonatomic, copy, readonly)       NSString*           path;
@property (nonatomic, copy, readonly)       NSString*           name;
@property (nonatomic, assign, readonly)     CGPDFDocumentRef    CGPDFDocument;

+ (NSString *)extension;
+ (instancetype)documentWithPath:(NSString *)path;

// Method to be called before rendering or any other processing the document. Initializes CGPDFDocument property.
- (void)openWithCompletion:(PDFDocumentOpenCompletionBlock)completion;
// Method to be called after all the work with the document is over. Sets CGPDFDocument property to NULL.
- (void)close;

@end

// A convenient declaration.
typedef NSObject<PDFDocumentProtocol> PDFDocument;

#endif
