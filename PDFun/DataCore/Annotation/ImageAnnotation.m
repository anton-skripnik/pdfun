//
//  ImageAnnotation.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "ImageAnnotation.h"

@implementation ImageAnnotation

- (void)renderInContext:(CGContextRef)context
{
    NSAssert(context != NULL, @"Cannot render with no context!");
    
    CGRect imageRect = CGRectMake(self.position.x, self.position.y, self.image.size.width, self.image.size.height);
    CGContextDrawImage(context, imageRect, self.image.CGImage);
}

@end
