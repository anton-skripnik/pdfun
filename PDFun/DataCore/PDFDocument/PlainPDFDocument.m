//
//  PlainPDFDocument.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PlainPDFDocument.h"
#import "Globals.h"
#import "PDFPage.h"

@interface PlainPDFDocument ()

@property (nonatomic, copy)             NSString*           path;
@property (nonatomic, assign)           CGPDFDocumentRef    CGPDFDocument;
@property (nonatomic, strong)           NSArray*            pages;

@end

@interface PlainPDFDocument (Private)

- (void)_buildPagesArray;

@end

@implementation PlainPDFDocument

+ (BOOL)requiresPassword
{
    return NO;
}

+ (NSString *)extension
{
    return @"pdf";
}

+ (instancetype)documentWithPath:(NSString *)path
{
    if ([path length] == 0)
    {
        DLog(@"Unable to create document with empty path.");
        return nil;
    }
    
    PlainPDFDocument* document = [[self alloc] init];
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path])
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
    
    NSURL* URL = [NSURL fileURLWithPath:self.path];
    self.CGPDFDocument = CGPDFDocumentCreateWithURL((CFURLRef)URL);
    if (self.CGPDFDocument != NULL)
    {
        [self _buildPagesArray];
    }
    
    if (completion)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            completion(self.CGPDFDocument != NULL);
        });
    }
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

@implementation PlainPDFDocument (Private)

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
