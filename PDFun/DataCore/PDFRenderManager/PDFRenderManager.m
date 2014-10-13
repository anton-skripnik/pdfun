//
//  PDFRenderManager.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PDFRenderManager.h"
#import "Globals.h"

@interface PDFRenderManager (Private)

- (CGAffineTransform)_drawingTransformForPage:(PDFPage *)page fittingIntoRect:(CGRect)boundingRect;

@end

@implementation PDFRenderManager

- (void)renderStandaloneAnnotation:(Annotation *)annotation inContext:(CGContextRef)context forPage:(PDFPage *)page fitIntoSize:(CGSize)size
{
    NSASSERT_NOT_NIL(annotation);
    NSAssert(context != NULL, @"Need a context to draw into!");
    NSASSERT_NOT_NIL(page);
    
    CGRect boundingRect = CGRectMake(0, 0, size.width, size.height);
    CGAffineTransform pageTransform = [self _drawingTransformForPage:page fittingIntoRect:boundingRect];
    CGContextConcatCTM(context, pageTransform);
    
    CGContextTranslateCTM(context, annotation.position.x, annotation.position.y);
    [annotation renderInContext:context];
}

- (void)renderPage:(PDFPage *)page inContext:(CGContextRef)context size:(CGSize)size
{
    NSASSERT_NOT_NIL(page);
    NSAssert(context != NULL, @"Need a context to draw into!");
    
    CGRect boundingRect = CGRectMake(0, 0, size.width, size.height);
    
    CGContextSetFillColorWithColor(context, page.backgroundColor.CGColor);
    CGContextFillRect(context, boundingRect);
    
    CGPDFPageRef CGPage = page.CGPDFPage;
    CGAffineTransform pageTransform = [self _drawingTransformForPage:page fittingIntoRect:boundingRect];
    CGContextConcatCTM(context, pageTransform);
    CGContextDrawPDFPage(context, CGPage);
    
    [page.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSASSERT_OF_CLASS(obj, Annotation);
        Annotation* annotation = obj;
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, annotation.position.x, annotation.position.y);
        [annotation renderInContext:context];
        CGContextRestoreGState(context);
    }];
}

- (void)renderDocument:(NSObject<PDFDocumentProtocol> *)document saveToURL:(NSURL *)PDFURL
{
    CGContextRef pdfContext = CGPDFContextCreateWithURL((CFURLRef)PDFURL, NULL, NULL);
    [document.pages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSASSERT_OF_CLASS(obj, PDFPage);
        PDFPage* page = obj;
        
        CGRect mediaBoxFrame = page.mediaBoxRect;
        NSData* pdfPageSizeData = [NSData dataWithBytes:&mediaBoxFrame length:sizeof(mediaBoxFrame)];
        NSDictionary* pdfPageDictionary = @{ (id)kCGPDFContextMediaBox: pdfPageSizeData };
        CGPDFContextBeginPage(pdfContext, (CFDictionaryRef)pdfPageDictionary);
        [self renderPage:page inContext:pdfContext size:mediaBoxFrame.size];
        CGPDFContextEndPage(pdfContext);
    }];
    CGContextRelease(pdfContext);
}

- (CGPoint)convertedPoint:(CGPoint)point intoCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect
{
    CGAffineTransform pageDrawingTransform = [self _drawingTransformForPage:page fittingIntoRect:boundingRect];
    CGAffineTransform invertedDrawingTransform = CGAffineTransformInvert(pageDrawingTransform);
    return CGPointApplyAffineTransform(point, invertedDrawingTransform);
}

- (CGPoint)convertedPoint:(CGPoint)point fromCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect
{
    CGAffineTransform pageDrawingTransform = [self _drawingTransformForPage:page fittingIntoRect:boundingRect];
    return CGPointApplyAffineTransform(point, pageDrawingTransform);
}

- (CGRect)convertedRect:(CGRect)rect intoCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect
{
    CGAffineTransform pageDrawingTransform = [self _drawingTransformForPage:page fittingIntoRect:boundingRect];
    CGAffineTransform invertedDrawingTransform = CGAffineTransformInvert(pageDrawingTransform);
    return CGRectApplyAffineTransform(rect, invertedDrawingTransform);
}

- (CGRect)convertedRect:(CGRect)rect fromCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect
{
    CGAffineTransform pageDrawingTransform = [self _drawingTransformForPage:page fittingIntoRect:boundingRect];
    return CGRectApplyAffineTransform(rect, pageDrawingTransform);
}

@end

#pragma mark - Private methods -

@implementation PDFRenderManager (Private)

- (CGAffineTransform)_drawingTransformForPage:(PDFPage *)page fittingIntoRect:(CGRect)boundingRect
{
    return CGPDFPageGetDrawingTransform(page.CGPDFPage,
                                        kCGPDFMediaBox,
                                        boundingRect,
                                        0,
                                        true);
}

@end
