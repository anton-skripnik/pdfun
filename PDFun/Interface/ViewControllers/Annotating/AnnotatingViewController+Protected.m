//
//  AnnotatingViewController+Protected.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "AnnotatingViewController+Protected.h"

@implementation AnnotatingViewController (Protected)

@dynamic pageView;

- (void)cancel
{
    [self.delegate annotatingViewControllerRequestsDimsissing:self];
}

- (void)accept
{
    [self.delegate annotatingViewControllerRequestsDimsissing:self];
}

@end
