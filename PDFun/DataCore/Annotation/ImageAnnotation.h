//
//  ImageAnnotation.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Annotation.h"

//
//  An annotation in form of image on top of a PDF page.
//
@interface ImageAnnotation : Annotation

@property (nonatomic, strong)   UIImage*    image;

@end
