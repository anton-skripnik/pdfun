//
//  Annotation.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

//
//  An abstract class for concrete annotation classes to inherit from.
//
@interface Annotation : NSObject

// A reference point for annotation to render its content from.
@property (nonatomic, assign)           CGPoint         position;

// That's the most basic thing neccessary of a concrete annotation: to render itself nicely.
// NOTE: Probably, annotations will alter context's properties back and forth, so it's a
// nice idea not to forget saving context state before the rendering and restoring it afterwards.
// TODO: Measure the performance and decide if the idea is actually nice.
- (void)renderInContext:(CGContextRef)context;

@end
