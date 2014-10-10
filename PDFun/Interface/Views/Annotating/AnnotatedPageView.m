//
//  AnnotatedPageView.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "AnnotatedPageView.h"

@implementation AnnotatedPageView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (!self.renderManager)
    {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip to have Core Graphics native coordinate system.
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    [self.renderManager renderPage:self.page inContext:context size:self.bounds.size];
}

@end