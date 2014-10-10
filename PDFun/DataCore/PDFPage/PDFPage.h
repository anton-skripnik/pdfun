//
//  PDFPage.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PDFDocument.h"

//
//  An object to represent pages of PDF document. Encapsulates CGPDFPageRef in it and
//  added annotations.
//
@interface PDFPage : NSObject

// Link to the containing document.
@property (nonatomic, weak, readonly)   PDFDocument*    document;
@property (nonatomic, assign, readonly) NSUInteger      index;
@property (nonatomic, assign, readonly) CGPDFPageRef    CGPDFPage;
@property (nonatomic, assign, readonly) CGRect          mediaBoxRect;
@property (nonatomic, strong, readonly) NSMutableArray* annotations;
@property (nonatomic, strong)           UIColor*        backgroundColor;

+ (instancetype)pageWithDocument:(PDFDocument *)document pageIndex:(NSUInteger)index;

@end
