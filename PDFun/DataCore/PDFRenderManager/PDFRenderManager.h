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

- (void)renderStandaloneAnnotation:(Annotation *)annotation inContext:(CGContextRef)context forPage:(PDFPage *)page fitIntoSize:(CGSize)size;
- (void)renderPage:(PDFPage *)page inContext:(CGContextRef)context size:(CGSize)size;
- (void)renderDocument:(PDFDocument *)document saveToURL:(NSURL *)PDFURL;

- (CGPoint)convertedPoint:(CGPoint)point intoCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect;
- (CGPoint)convertedPoint:(CGPoint)point fromCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect;
- (CGRect)convertedRect:(CGRect)rect intoCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect;
- (CGRect)convertedRect:(CGRect)rect fromCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect;

@end
