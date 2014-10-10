//
//  PDFPage.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PDFPage.h"
#import "Globals.h"

#define DEFAULT_BACKGROUND_COLOR            [UIColor whiteColor]

@interface PDFPage ()

@property (nonatomic, weak)     PDFDocument*    document;
@property (nonatomic, assign)   NSUInteger      index;
@property (nonatomic, strong)   NSMutableArray* annotations;

@end

@implementation PDFPage

+ (instancetype)pageWithDocument:(NSObject<PDFDocumentProtocol> *)document pageIndex:(NSUInteger)index
{
    NSASSERT_NOT_NIL(document);
    NSAssert(document.CGPDFDocument != NULL, @"Cannot create a page with non-open document!");
    NSAssert(index > 0, @"PDF's first page index is 1");
    NSAssert(index <= CGPDFDocumentGetNumberOfPages(document.CGPDFDocument), @"Index is larger than number of pages in the document!");

    PDFPage* newPage = [[self alloc] init];
    newPage.document = document;
    newPage.index = index;
    newPage.annotations = [NSMutableArray array];
    newPage.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    return newPage;
}

- (CGPDFPageRef)CGPDFPage
{
    if (self.document == nil || self.document.CGPDFDocument == NULL)
    {
        // self.document is weak. Might be nil.
        return NULL;
    }
    
    return CGPDFDocumentGetPage(self.document.CGPDFDocument, self.index);
}

- (CGRect)mediaBoxRect
{
    CGPDFPageRef CGPDFPage = self.CGPDFPage;
    if (CGPDFPage == NULL)
    {
        return CGRectZero;
    }
    
    return CGPDFPageGetBoxRect(CGPDFPage, kCGPDFMediaBox);
}

@end
