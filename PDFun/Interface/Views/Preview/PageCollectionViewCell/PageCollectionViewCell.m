//
//  PreviewCollectionViewCell.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PageCollectionViewCell.h"
#import "PDFRenderManager.h"
#import "Globals.h"

@interface PageCollectionViewCell ()

@property (nonatomic, strong)   CALayer*    pageLayer;

@end

@interface PageCollectionViewCell (Private)

- (void)_obtainPageLayerIfNecessary;

@end

@implementation PageCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.pageLayer removeFromSuperlayer];
    self.pageLayer = nil;
}

- (void)setPage:(PDFPage *)page
{
    _page = page;
    [self _obtainPageLayerIfNecessary];
}

- (void)setRenderManager:(PDFRenderManager *)renderManager
{
    _renderManager = renderManager;
    [self _obtainPageLayerIfNecessary];
}

- (void)refresh
{
    [self.pageLayer removeFromSuperlayer];
    self.pageLayer = nil;
    
    [self _obtainPageLayerIfNecessary];
}

@end

@implementation PageCollectionViewCell (Private)

- (void)_obtainPageLayerIfNecessary
{
    if (!self.page || !self.renderManager || self.pageLayer)
    {
        return;
    }
    
    self.pageLayer = [self.renderManager layerForPage:self.page withSize:self.bounds.size];
    self.pageLayer.backgroundColor = [[UIColor greenColor] CGColor];
    [self.layer addSublayer:self.pageLayer];
    self.pageLayer.anchorPoint = CGPointZero;
    self.pageLayer.position = CGPointZero;
}

@end