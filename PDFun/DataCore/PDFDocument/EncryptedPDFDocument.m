//
//  EncryptedPDFDocument.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "EncryptedPDFDocument.h"
#import "Globals.h"
#import "Cryptor.h"
#import "TemporaryStorageManager.h"
#import "PDFPage.h"

@interface EncryptedPDFDocument()

@property (nonatomic, copy)         NSString*           path;
@property (nonatomic, assign)       CGPDFDocumentRef    CGPDFDocument;
@property (nonatomic, strong)       NSArray*            pages;

@end

@interface EncryptedPDFDocument (Private)

- (void)_buildPagesArray;

@end

@implementation EncryptedPDFDocument

+ (BOOL)requiresPassword
{
    return YES;
}

+ (NSString *)extension
{
    return @"epd";
}

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

- (void)openWithCompletion:(PDFDocumentOpenCompletionBlock)completion
{
    NSASSERT_NOT_NIL(self.password);

    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.path])
    {
        DLog(@"Failed to find file at %@", self.path);
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completion(NO);
            });
        }
        return;
    }
    
    NSString* temporaryEncryptedCopyPath = [[TemporaryStorageManager sharedManager] pathForNamePrefix:self.name ofType:[[self class] extension]];
    NSError* copyingError = nil;
    if (![fileManager copyItemAtPath:self.path toPath:temporaryEncryptedCopyPath error:&copyingError])
    {
        DLog(@"Error copying an encrypted file %@ into the temporary location %@", self.path, temporaryEncryptedCopyPath);
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completion(NO);
            });
        }
        return;
    }
    
    NSMutableData* pdfData = [NSMutableData data];
    Cryptor* __block cryptor = [[Cryptor alloc] init];
    [cryptor decryptSourceBinaryAt:temporaryEncryptedCopyPath
                       intoPDFData:pdfData
                      withPassword:self.password
                        completion:^(NSError *error)
    {
        [fileManager removeItemAtPath:temporaryEncryptedCopyPath error:nil];
        
        if (error)
        {
            if (completion)
            {
                completion(NO);
            }
        }
        else
        {
            CGDataProviderRef pdfDataProvider = CGDataProviderCreateWithCFData((__bridge  CFDataRef)pdfData);
            self.CGPDFDocument = CGPDFDocumentCreateWithProvider(pdfDataProvider);
            CGDataProviderRelease(pdfDataProvider);
            
            if (!self.CGPDFDocument)
            {
                DLog(@"Failed to create a CGPDFDocumentRef!");
                if (completion)
                {
                    completion(NO);
                }
            }
            else
            {
                [self _buildPagesArray];
                if (completion)
                {
                    completion(YES);
                }
            }
        }
        
        cryptor = nil;
    }];
}

- (void)close
{
    if (self.CGPDFDocument)
    {
        CGPDFDocumentRelease(self.CGPDFDocument), self.CGPDFDocument = NULL;
    }
    if (self.pages)
    {
        self.pages = nil;
    }
}

@end

#pragma mark - Private methods -

@implementation EncryptedPDFDocument (Private)

- (void)_buildPagesArray
{
    NSAssert(self.CGPDFDocument != NULL, @"Unable to create pages array before the document is open!");
    
    NSMutableArray* pages = [NSMutableArray array];
    for (int i = 1; i <= CGPDFDocumentGetNumberOfPages(self.CGPDFDocument); i++)
    {
        [pages addObject:[PDFPage pageWithDocument:self pageIndex:i]];
    }
    
    self.pages = pages;
}

@end