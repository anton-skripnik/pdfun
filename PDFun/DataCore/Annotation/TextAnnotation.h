//
//  TextAnnotation.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Annotation.h"

//
//  An annotation consisting of arbitrary text somewhere on a PDF page.
//
@interface TextAnnotation : Annotation

@property (nonatomic, copy)     NSString*           text;
@property (nonatomic, strong)   UIColor*            textColor;
@property (nonatomic, strong)   UIFont*             font;

@end
