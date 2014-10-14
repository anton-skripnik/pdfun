//
//  PDFRenderManager.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFDocument.h"
#import "PDFPage.h"
#import "Annotation.h"

//
//  An object to manage rendering stuff (both on screen and into a PDF file).
//
@interface PDFRenderManager : NSObject

- (void)renderPage:(PDFPage *)page inContext:(CGContextRef)context size:(CGSize)size;
- (void)renderDocument:(PDFDocument *)document intoMutableData:(NSMutableData *)data;

- (CGPoint)convertedPoint:(CGPoint)point intoCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect;

// Creates a layer of given size to represent the contents of the PDF page.
// Manages an internal cache and returns an element of the cache instead of redrawing each time.
- (CALayer *)layerForPage:(PDFPage *)page withSize:(CGSize)size;
// Like the previous method, but always returns new instances of CALayer. Though, their contents
// are identical to the original page layer in cache.
- (CALayer *)layerWithContentsOfLayerForPage:(PDFPage *)page withSize:(CGSize)size;
// Removes a layer associated with the page from the internal cache, forcing the manager to
// rerender the page during next -layerForPage: invocation.
- (void)invalidateLayerForPage:(PDFPage *)page;

// Creates a layer for the given annotation to be rendered atop of the given page.
// Unlike the page layers, annotation layer's contents is relatively inexpensive to redraw, so
// annotation layers are not cached and their contents is not populated at the time of creation.
// Instead, it's provided by the manager each time the layer needs to be redrawn.
- (CALayer *)layerForAnnotation:(Annotation *)annotation forPage:(PDFPage *)page pageSize:(CGSize)pageSize;

@end
