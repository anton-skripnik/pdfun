//
//  AnnotatingViewController+Protected.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "AnnotatingViewController+Protected.h"
#import "Globals.h"

@implementation AnnotatingViewController (Protected)

@dynamic pageView;

- (Annotation *)editedAnnotation
{
    ENSURE_METHOD_IS_OVERRIDEN;
}

- (void)cancel
{
    [self.page.annotations removeObject:[self editedAnnotation]];
    [self.delegate annotatingViewControllerRequestsDimsissing:self];
}

- (void)accept
{
    [self.delegate annotatingViewControllerRequestsDimsissing:self];
}

@end
