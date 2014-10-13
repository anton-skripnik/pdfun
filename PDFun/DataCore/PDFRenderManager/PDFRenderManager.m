//
//  PDFRenderManager.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PDFRenderManager.h"
#import "Globals.h"


#pragma mark - AnnotationLayer class declaration -

//
//  Class for layers to store an annotation while it's being edited in an Annotating view controller.
//
@interface AnnotationLayer : CALayer

@property (nonatomic, strong)       Annotation*         annotation;
@property (nonatomic, strong)       PDFPage*            page;

@end
@implementation AnnotationLayer @end


#pragma mark - PDFRenderManager implementations -

@interface PDFRenderManager ()

@property (nonatomic, strong)       NSCache*            pageLayersCache;

@end
@interface PDFRenderManager (CALayerDelegate) @end
@interface PDFRenderManager (Private)

- (CGAffineTransform)_drawingTransformForPage:(PDFPage *)page fittingIntoRect:(CGRect)boundingRect;
// Creates a temporary bitmap context for the layer, calls the drawing instructions, gets an image and sets it as a
// contents property's value for the mentioned layer.
// NOTE: contentsScale and bounds properties have to be set correctly before using this method.
- (void)_populateContentsOfLayer:(CALayer *)layer withResultOfDrawingInstructionsInBlock:(void (^)(CGContextRef context))drawingInstructionsBlock;
- (CALayer *)_layerOfClass:(Class)layerClass withSize:(CGSize)layerSize;

@end

@implementation PDFRenderManager

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.pageLayersCache = [[NSCache alloc] init];
    }
    
    return self;
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

- (CALayer *)layerForPage:(PDFPage *)page withSize:(CGSize)size
{
    NSASSERT_NOT_NIL(page);
    
    if (size.width == 0 || size.height == 0)
    {
        return nil;
    }
    
    id cachedInstance = [self.pageLayersCache objectForKey:page];
    if (cachedInstance)
    {
        NSASSERT_OF_CLASS(cachedInstance, CALayer);
        CALayer* cachedLayer = (CALayer *)cachedInstance;
        
        if (CGSizeEqualToSize(cachedLayer.bounds.size, size))
        {
            return cachedLayer;
        }
    }
    
    CALayer* layer = [self _layerOfClass:[CALayer class] withSize:size];
    [self _populateContentsOfLayer:layer withResultOfDrawingInstructionsInBlock:^(CGContextRef context)
    {
        [self renderPage:page inContext:context size:size];
    }];
    
    [self.pageLayersCache setObject:layer forKey:page];
    
    return layer;
}

- (CALayer *)layerWithContentsOfLayerForPage:(PDFPage *)page withSize:(CGSize)size
{
    CALayer* originalLayer = [self layerForPage:page withSize:size];
    CALayer* copyLayer = [self _layerOfClass:[CALayer class] withSize:size];
    copyLayer.contents = originalLayer.contents;
    
    return copyLayer;
}

- (void)invalidateLayerForPage:(PDFPage *)page
{
    NSASSERT_NOT_NIL(page);
    [self.pageLayersCache removeObjectForKey:page];
}

- (CALayer *)layerForAnnotation:(Annotation *)annotation forPage:(PDFPage *)page pageSize:(CGSize)pageSize
{
    NSASSERT_NOT_NIL(annotation);
    NSASSERT_NOT_NIL(page);
    
    if (pageSize.width == 0 || pageSize.height == 0)
    {
        return nil;
    }
    
    AnnotationLayer* layer = (AnnotationLayer *)[self _layerOfClass:[AnnotationLayer class] withSize:pageSize];
    layer.annotation = annotation;
    layer.page = page;
    layer.delegate = self;
    
    return layer;
}

@end

#pragma mark - CALayerDelegate methods -

@implementation PDFRenderManager (CALayerDelegate)

- (void)displayLayer:(CALayer *)layer
{
    NSASSERT_OF_CLASS(layer, AnnotationLayer);
    AnnotationLayer* annotationLayer = (AnnotationLayer *)layer;
    NSASSERT_NOT_NIL(annotationLayer.annotation);
    NSASSERT_NOT_NIL(annotationLayer.page);
    
    [self _populateContentsOfLayer:annotationLayer withResultOfDrawingInstructionsInBlock:^(CGContextRef context)
    {
        CGAffineTransform pageTransform = [self _drawingTransformForPage:annotationLayer.page fittingIntoRect:annotationLayer.bounds];
        CGContextConcatCTM(context, pageTransform);
        
        CGContextTranslateCTM(context, annotationLayer.annotation.position.x, annotationLayer.annotation.position.y);
        [annotationLayer.annotation renderInContext:context];
    }];
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

- (void)_populateContentsOfLayer:(CALayer *)layer withResultOfDrawingInstructionsInBlock:(void (^)(CGContextRef))drawingInstructionsBlock
{
    NSASSERT_NOT_NIL(layer);
    NSASSERT_NOT_NIL(drawingInstructionsBlock);
    
    int bitmapContextWidth = (int)(layer.bounds.size.width * layer.contentsScale);
    int bitmapContextHeight = (int)(layer.bounds.size.height * layer.contentsScale);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       bitmapContextWidth,
                                                       bitmapContextHeight,
                                                       8,
                                                       4 * bitmapContextWidth,
                                                       colorSpace,
                                                       (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextScaleCTM(bitmapContext, layer.contentsScale, layer.contentsScale);
    
    drawingInstructionsBlock(bitmapContext);
    
    CGImageRef renderedPageImage = CGBitmapContextCreateImage(bitmapContext);
    layer.contents = (__bridge id)renderedPageImage;
    CGImageRelease(renderedPageImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapContext);
}

- (CALayer *)_layerOfClass:(Class)layerClass withSize:(CGSize)layerSize
{
    NSAssert([layerClass isSubclassOfClass:[CALayer class]], @"Invalid layer class %@", [layerClass description]);

    CALayer* layer = [layerClass layer];
    CGRect layerBounds = CGRectZero;
    layerBounds.size = layerSize;
    layer.bounds = layerBounds;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    // Turn off the implicit animations.
    layer.actions = @{ @"position" : [NSNull null], @"anchorPoint" : [NSNull null], @"contents" : [NSNull null] };
    
    return layer;
}

@end
