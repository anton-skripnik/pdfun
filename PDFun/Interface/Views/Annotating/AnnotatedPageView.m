//
//  AnnotatedPageView.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "AnnotatedPageView.h"
#import "Globals.h"

@interface AnnotatedPageView ()

// This layer contains the page and all the annotations (besides the one currently edited) rendered.
// Its content never changes and is drawn only once.
@property (nonatomic, strong)   CALayer*            pageLayer;
// This layer represents the currently edited annotation. Its content changes all the time on -updateAnnotation
// method invocation.
@property (nonatomic, strong)   CALayer*            annotationLayer;

@end

@interface AnnotatedPageView (Private)

- (void)_createPageLayer;
- (void)_updatePageLayer;
- (void)_createAnnotationLayer;
- (void)_updateAnnotationLayer;

@end

@implementation AnnotatedPageView

- (void)updateAnnotation
{
    [self _updateAnnotationLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _updatePageLayer];
    [self _updateAnnotationLayer];
}

- (void)setPage:(PDFPage *)page
{
    _page = page;
    [self _updatePageLayer];
    [self _updateAnnotationLayer];
}

- (void)setAnnotation:(Annotation *)annotation
{
    _annotation = annotation;
    [self _updateAnnotationLayer];
}

- (void)setRenderManager:(PDFRenderManager *)renderManager
{
    _renderManager = renderManager;
    [self _updatePageLayer];
    [self _updateAnnotationLayer];
}

@end

#pragma mark - Private methods -

@implementation AnnotatedPageView (Private)

- (void)_createPageLayer
{
    self.pageLayer = [CALayer layer];
    self.pageLayer.contentsScale = [[UIScreen mainScreen] scale];
    self.pageLayer.actions = @{ @"contents": [NSNull null] };
    [self.layer addSublayer:self.pageLayer];
}

- (void)_updatePageLayer
{
    if (!self.page || !self.renderManager)
    {
        return;
    }

    if (!self.pageLayer)
    {
        [self _createPageLayer];
    }
    
    self.pageLayer.bounds = self.bounds;
    self.pageLayer.anchorPoint = CGPointMake(0.5, 0.5);
    self.pageLayer.position = CGPointMake(roundf(self.bounds.size.width * 0.5), roundf(self.bounds.size.height * 0.5));
    
    int bitmapWidth = self.bounds.size.width * self.pageLayer.contentsScale;
    int bitmapHeight = self.bounds.size.height * self.pageLayer.contentsScale;
    
    if (bitmapWidth == 0 || bitmapHeight == 0)
    {
        return;
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef pageLayerContentBitmapContext = CGBitmapContextCreate(NULL,
                                                                       bitmapWidth,
                                                                       bitmapHeight,
                                                                       8,
                                                                       4 * bitmapWidth,
                                                                       colorspace,
                                                                       (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextScaleCTM(pageLayerContentBitmapContext, self.pageLayer.contentsScale, self.pageLayer.contentsScale);
    [self.renderManager renderPage:self.page inContext:pageLayerContentBitmapContext size:self.bounds.size];
    
    CGImageRef pageLayerContentsImage = CGBitmapContextCreateImage(pageLayerContentBitmapContext);
    self.pageLayer.contents = (__bridge id)pageLayerContentsImage;
    
    CGColorSpaceRelease(colorspace);
    CGContextRelease(pageLayerContentBitmapContext);
    CGImageRelease(pageLayerContentsImage);
}

- (void)_createAnnotationLayer
{
    self.annotationLayer = [CALayer layer];
    self.annotationLayer.contentsScale = [[UIScreen mainScreen] scale];
    self.annotationLayer.actions = @{ @"contents": [NSNull null] };
    [self.layer addSublayer:self.annotationLayer];
}

- (void)_updateAnnotationLayer
{
    if (!self.page || !self.annotation || !self.renderManager)
    {
        return;
    }

    if (!self.annotationLayer)
    {
        [self _createAnnotationLayer];
    }

    self.annotationLayer.bounds = self.bounds;
    self.annotationLayer.anchorPoint = CGPointZero;
    self.annotationLayer.position = CGPointZero;
    
    int bitmapWidth = self.bounds.size.width * self.pageLayer.contentsScale;
    int bitmapHeight = self.bounds.size.height * self.pageLayer.contentsScale;
    
    if (bitmapWidth == 0 || bitmapHeight == 0)
    {
        return;
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef annotationLayerContentBitmapContext = CGBitmapContextCreate(NULL,
                                                                             bitmapWidth,
                                                                             bitmapHeight,
                                                                             8,
                                                                             4 * bitmapWidth,
                                                                             colorspace,
                                                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextScaleCTM(annotationLayerContentBitmapContext, self.pageLayer.contentsScale, self.pageLayer.contentsScale);
    [self.renderManager renderStandaloneAnnotation:self.annotation
                                         inContext:annotationLayerContentBitmapContext
                                           forPage:self.page
                                       fitIntoSize:self.bounds.size];
    
    CGImageRef annotationLayerContentsImage = CGBitmapContextCreateImage(annotationLayerContentBitmapContext);
    self.annotationLayer.contents = (__bridge id)annotationLayerContentsImage;
    
    CGColorSpaceRelease(colorspace);
    CGContextRelease(annotationLayerContentBitmapContext);
    CGImageRelease(annotationLayerContentsImage);
}

@end