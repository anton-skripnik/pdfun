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

//
//  An object to manage rendering stuff (both on screen and into a PDF file).
//
@interface PDFRenderManager : NSObject

- (void)renderPage:(PDFPage *)page inContext:(CGContextRef)context size:(CGSize)size;
- (void)renderDocument:(PDFDocument *)document saveToURL:(NSURL *)PDFURL;
- (CGPoint)convertedPoint:(CGPoint)point intoCoordinateSystemOfPage:(PDFPage *)page fitIntoRect:(CGRect)boundingRect;

@end
