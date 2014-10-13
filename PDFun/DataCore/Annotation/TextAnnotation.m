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
    
    UIFont* font = self.font;
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary* attributes =
    @{
      (__bridge NSString *)kCTFontAttributeName: (__bridge id)ctFont,
      (__bridge NSString *)kCTForegroundColorAttributeName: (__bridge id)self.textColor.CGColor,
    };
    NSAttributedString* textAttributedString = [[NSAttributedString alloc] initWithString:self.text
                                                                               attributes:attributes];
    CFRelease(ctFont);
    
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)textAttributedString);
    CGContextSetTextPosition(context, 0, 0);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CTLineDraw(line, context);
    CFRelease(line);
}

@end
