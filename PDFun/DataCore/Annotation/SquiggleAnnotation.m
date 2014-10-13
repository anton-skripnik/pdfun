//
//  SquiggleAnnotation.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "SquiggleAnnotation.h"
#import "Globals.h"

#define DEFAULT_LINE_WIDTH                          10.0
#define DEFAULT_LINE_COLOR                          [UIColor redColor]

@interface SquiggleAnnotation ()

@property (nonatomic, strong)   NSMutableArray*     mutablePoints;
@property (nonatomic, assign)   CGMutablePathRef    squigglePath;

@end

@implementation SquiggleAnnotation

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.mutablePoints = [NSMutableArray array];
        self.lineWidth = DEFAULT_LINE_WIDTH;
        self.lineColor = DEFAULT_LINE_COLOR;
    }
    
    return self;
}

- (void)dealloc
{
    if (self.squigglePath != NULL)
    {
        CGPathRelease(self.squigglePath), self.squigglePath = NULL;
    }
}

- (NSArray *)points
{
    return self.mutablePoints;
}

- (void)addPoint:(CGPoint)point
{
    [self.mutablePoints addObject:[NSValue valueWithCGPoint:point]];
    if (self.renderUsingPath)
    {
        NSAssert(self.squigglePath != NULL, @"The path should have been initialized by the time!");
        CGPathAddLineToPoint(self.squigglePath, NULL, point.x, point.y);
    }
}

- (void)setRenderUsingPath:(BOOL)renderUsingPath
{
    if (renderUsingPath != _renderUsingPath)
    {
        _renderUsingPath = renderUsingPath;
        if (!renderUsingPath)
        {
            if (self.squigglePath != NULL)
            {
                CGPathRelease(self.squigglePath), self.squigglePath = NULL;
            }
        }
        else
        {
            if (self.squigglePath != NULL)
            {
                CGPathRelease(self.squigglePath), self.squigglePath = NULL;
            }
            
            self.squigglePath = CGPathCreateMutable();
            CGPathMoveToPoint(self.squigglePath, NULL, 0, 0);
            [self.points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                NSASSERT_OF_CLASS(obj, NSValue);
                NSValue* currentPointValue = obj;
                CGPoint currentPoint = currentPointValue.CGPointValue;
                CGPathAddLineToPoint(self.squigglePath, NULL, currentPoint.x, currentPoint.y);
            }];
        }
    }
}

- (void)renderInContext:(CGContextRef)context
{
    NSAssert(context != NULL, @"Cannot render with no context!");
    if (self.points.count == 0)
    {
        return;
    }
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    
    CGContextMoveToPoint(context, 0, 0);
    
    if (self.renderUsingPath && self.squigglePath != NULL)
    {
        CGContextAddPath(context, self.squigglePath);
    }
    else
    {
        for (NSUInteger ptIndex = 0; ptIndex < self.points.count; ptIndex++)
        {
            NSASSERT_OF_CLASS(self.points[ptIndex], NSValue);
            NSValue* currentPointValue = self.points[ptIndex];
            CGPoint currentPoint = [currentPointValue CGPointValue];
            CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        }
    }
    
    CGContextStrokePath(context);
}

@end
