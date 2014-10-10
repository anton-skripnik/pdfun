//
//  SquiggleAnnotation.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "SquiggleAnnotation.h"

#define DEFAULT_LINE_WIDTH                      1.0
#define DEFAULT_LINE_COLOR                      [UIColor redColor]

@implementation SquiggleAnnotation

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.points = [NSMutableArray array];
        self.lineWidth = DEFAULT_LINE_WIDTH;
        self.lineColor = DEFAULT_LINE_COLOR;
    }
    
    return self;
}

- (void)renderInContext:(CGContextRef)context
{
    NSAssert(context != NULL, @"Cannot render with no context!");
    if (self.points.count < 2)
    {
        return;
    }
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    
    CGPoint initialPoint = [self.points.firstObject CGPointValue];
    CGContextMoveToPoint(context, self.position.x + initialPoint.x, self.position.y + initialPoint.y);
    
    for (NSUInteger ptIndex = 1; ptIndex < self.points.count; ptIndex++)
    {
        CGPoint currentPoint = [self.points[ptIndex] CGPointValue];
        CGContextAddLineToPoint(context, self.position.x + currentPoint.x, self.position.y + currentPoint.y);
    }
    
    CGContextStrokePath(context);
}

@end
