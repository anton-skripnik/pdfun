//
//  AnnotatingViewController+Protected.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "AnnotatingViewController.h"
#import "AnnotatedPageView.h"
#import "Annotation.h"

@interface AnnotatingViewController (Protected)

// Defined in the base class's m-file.
@property (nonatomic, strong, readonly)     AnnotatedPageView*  pageView;

// Subclasses must override and return the instance of their respective
// annotation class they're working with.
- (Annotation *)editedAnnotation;

// Subclasses may override the methods in order to react on navigation bar items
// activation.
- (void)cancel;
- (void)accept;

@end
