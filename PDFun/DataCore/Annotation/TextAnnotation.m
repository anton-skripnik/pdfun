//
//  TextAnnotation.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "TextAnnotation.h"
#import <CoreText/CoreText.h>

#define DEFAULT_TEXT_COLOR              [UIColor redColor]
#define DEFAULT_FONT                    [UIFont systemFontOfSize:24.0]

@implementation TextAnnotation

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.textColor = DEFAULT_TEXT_COLOR;
        self.font = DEFAULT_FONT;
    }
    
    return self;
}

- (void)renderInContext:(CGContextRef)context
{
    NSAssert(context != NULL, @"Cannot render with no context!");
    
    if (self.text.length == 0)
    {
        return;
    }
    
    NSAttributedString* textAttributedString = [[NSAttributedString alloc] initWithString:self.text
                                                                               attributes:
                                                                               @{
                                                                                    NSFontAttributeName: self.font,
                                                                                    NSForegroundColorAttributeName: self.textColor,
                                                                               }];
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)textAttributedString);
    CGContextSetTextPosition(context, self.position.x, self.position.y);
    CGContextSetTextDrawingMode(context, kCGTextFillStrokeClip);
    CTLineDraw(line, context);
    
    CFRelease(line);
}

@end
