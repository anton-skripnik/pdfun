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
    
    [self _createPageLayer];
    [self _createAnnotationLayer];
}

- (void)setPage:(PDFPage *)page
{
    _page = page;
    [self _createPageLayer];
    [self _createAnnotationLayer];
}

- (void)setAnnotation:(Annotation *)annotation
{
    _annotation = annotation;
    [self _createAnnotationLayer];
}

- (void)setRenderManager:(PDFRenderManager *)renderManager
{
    _renderManager = renderManager;
    [self _createPageLayer];
    [self _createAnnotationLayer];
}

@end

#pragma mark - Private methods -

@implementation AnnotatedPageView (Private)

- (void)_createPageLayer
{
    if (!self.page || !self.renderManager)
    {
        return;
    }

    // Copy the layer not to steal it from currently owning superlayer.
    CALayer* pageLayer = [self.renderManager layerWithContentsOfLayerForPage:self.page withSize:self.bounds.size];
    self.pageLayer = pageLayer;
    self.pageLayer.anchorPoint = CGPointZero;
    self.pageLayer.position = CGPointZero;
    [self.layer addSublayer:self.pageLayer];
}

- (void)_createAnnotationLayer
{
    if (!self.renderManager || !self.page || !self.annotation)
    {
        return;
    }

    self.annotationLayer = [self.renderManager layerForAnnotation:self.annotation forPage:self.page pageSize:self.bounds.size];
    self.annotationLayer.anchorPoint = CGPointZero;
    self.annotationLayer.position = CGPointZero;
    [self.layer addSublayer:self.annotationLayer];
    
    [self _updateAnnotationLayer];
}

- (void)_updateAnnotationLayer
{
    [self.annotationLayer setNeedsDisplay];
}

@end