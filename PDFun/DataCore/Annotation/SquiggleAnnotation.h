//
//  SquiggleAnnotation.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Annotation.h"

//
//  A concrete annotation representing a continuous line of arbitrary shape (aka squiggle).
//
@interface SquiggleAnnotation : Annotation

@property (nonatomic, strong)           NSMutableArray*     points;         // of NSValued CGPoints.

// Customization
@property (nonatomic, strong)           UIColor*            lineColor;
@property (nonatomic, assign)           CGFloat             lineWidth;

@end
