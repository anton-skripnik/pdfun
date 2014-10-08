//
//  EncryptedPDFDocument.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "EncryptedPDFDocument.h"
#import "Globals.h"

@interface EncryptedPDFDocument()

@property (nonatomic, copy)         NSString*           path;
@property (nonatomic, assign)       CGPDFDocumentRef    CGPDFDocument;

@end

@implementation EncryptedPDFDocument

+ (instancetype)documentWithPath:(NSString *)path
{
    if ([path length] == 0)
    {
        DLog(@"Unable to create document with empty path.");
        return nil;
    }
    
    EncryptedPDFDocument* document = [[self alloc] init];
    document.path = path;
    
    return document;
}

- (void)dealloc
{
    [self close];
}

- (NSString *)name
{
    return [[self.path lastPathComponent] stringByDeletingPathExtension];
}

- (BOOL)open
{
    // 1. Copy the encrypted file into a temporary directory.
    // 2. Decrypt the file into a temporary PDF file and remove the encrypted copy from the temporary directory.
    // 3. Create the CGPDFDocumentRef with the temporary PDF.
    
    // TODO: Code the above.
    return NO;
}

- (void)close
{
    // 1. Release the CGPDFDocumentRef and NULL the property.
    // 2. Remove the temporary PDF file.
}

@end
