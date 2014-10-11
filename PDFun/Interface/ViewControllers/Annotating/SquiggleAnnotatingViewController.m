//
//  SquiggleAnnotatingViewController.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "SquiggleAnnotatingViewController.h"
#import "Globals.h"
#import "AnnotatingViewController+Protected.h"
#import "SquiggleAnnotation.h"


#define USAGE_HINT_TEXT                         @"Tap or drag to draw a line"
#define USAGE_HINT_FONT                         [UIFont systemFontOfSize:14.0]
#define USAGE_HINT_TEXT_COLOR                   [UIColor lightGrayColor]


@interface SquiggleAnnotatingViewController ()

@property (nonatomic, strong)           SquiggleAnnotation*         annotation;
@property (nonatomic, strong)           UIPanGestureRecognizer*     panGestureRecognizer;
@property (nonatomic, strong)           UITapGestureRecognizer*     tapGestureRecognizer;

@end

@interface SquiggleAnnotatingViewController (Private)

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r;
- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r;
- (void)_addSquigglePointWithRecognizedPosition:(CGPoint)p;

@end

@implementation SquiggleAnnotatingViewController

+ (Class)annotationClass
{
    return [SquiggleAnnotation class];
}

+ (NSString *)annotationTypeString
{
    return @"Squiggle";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* usageHintLabel = [[UILabel alloc] init];
    usageHintLabel.font = USAGE_HINT_FONT;
    usageHintLabel.text = USAGE_HINT_TEXT;
    usageHintLabel.textColor = USAGE_HINT_TEXT_COLOR;
    [usageHintLabel sizeToFit];
    UIBarButtonItem* hintBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:usageHintLabel];
    UIBarButtonItem* leftSpacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* rightSpacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[ leftSpacingItem, hintBarButtonItem, rightSpacingItem ];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.tapGestureRecognizer];
}

- (Annotation *)editedAnnotation
{
    return self.annotation;
}

@end

#pragma mark - Private methods -

@implementation SquiggleAnnotatingViewController (Private)

- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r
{
    if (r.state == UIGestureRecognizerStateBegan || r.state == UIGestureRecognizerStateChanged)
    {
        [self _addSquigglePointWithRecognizedPosition:[r locationInView:self.pageView]];
    }
}

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r
{
    [self _addSquigglePointWithRecognizedPosition:[r locationInView:self.pageView]];
}

- (void)_addSquigglePointWithRecognizedPosition:(CGPoint)p
{
    CGPoint actualPosition = CGPointZero;
    actualPosition.x = p.x;
    actualPosition.y = self.pageView.bounds.size.height - p.y;
    actualPosition = [self.renderManager convertedPoint:actualPosition
                             intoCoordinateSystemOfPage:self.page
                                            fitIntoRect:self.pageView.bounds];

    if (!self.annotation)
    {
        self.annotation = [[SquiggleAnnotation alloc] init];
        self.annotation.position = actualPosition;
        [self.page.annotations addObject:self.annotation];
    }
    
    CGPoint pointRelativeToPosition = CGPointZero;
    pointRelativeToPosition.x = actualPosition.x - self.annotation.position.x;
    pointRelativeToPosition.y = actualPosition.y - self.annotation.position.y;
    
    [self.annotation.points addObject:[NSValue valueWithCGPoint:pointRelativeToPosition]];
    
    [self.pageView setNeedsDisplay];
}

@end