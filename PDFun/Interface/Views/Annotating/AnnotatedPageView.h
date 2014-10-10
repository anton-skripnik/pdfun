//
//  AnnotatedPageView.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFPage.h"
#import "PDFRenderManager.h"

//
//  A view to display unchangable PDF content (including previously placed annotations) atop
//  of which the currently configured annotation is being moved around.
//
@interface AnnotatedPageView : UIView

@property (nonatomic, strong)   PDFPage*            page;
@property (nonatomic, weak)     PDFRenderManager*   renderManager;

@end
