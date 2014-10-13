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

@property (nonatomic, strong, readonly) NSArray*            points;         // of NSValued CGPoints.
// When NO, -renderInContext: will cause the object to go through points array and render the
// line along the way. When the property is set to YES, the object initializes a CGPath
// from its current points, adds new points to the path and uses the path when is asked to
// render. Should be more efficient if it's necessary to repaint the annotation often.
@property (nonatomic, assign)           BOOL                renderUsingPath;

// Customization
@property (nonatomic, strong)           UIColor*            lineColor;
@property (nonatomic, assign)           CGFloat             lineWidth;

- (void)addPoint:(CGPoint)point;

@end
