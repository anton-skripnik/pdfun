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
#define USAGE_HINT_FONT                         [UIFont systemFontOfSize:10.0]
#define USAGE_HINT_TEXT_COLOR                   [UIColor lightGrayColor]


@interface SquiggleAnnotatingViewController ()

@property (nonatomic, strong)           SquiggleAnnotation*         annotation;
@property (nonatomic, strong)           UIPanGestureRecognizer*     panGestureRecognizer;
@property (nonatomic, strong)           UITapGestureRecognizer*     tapGestureRecognizer;

@end

@interface SquiggleAnnotatingViewController (Private)

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r;
- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r;
- (void)_handleSuccessfulRecognitionBy:(UIGestureRecognizer *)r;
- (void)_addSquigglePoint:(CGPoint)p;

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

- (void)cancel
{
    [self.page.annotations removeObject:self.annotation];

    [super cancel];
}

@end

#pragma mark - Private methods -

@implementation SquiggleAnnotatingViewController (Private)

- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r
{
    if (r.state == UIGestureRecognizerStateBegan || r.state == UIGestureRecognizerStateChanged)
    {
        [self _handleSuccessfulRecognitionBy:r];
    }
}

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r
{
    [self _handleSuccessfulRecognitionBy:r];
}

- (void)_handleSuccessfulRecognitionBy:(UIGestureRecognizer *)r
{
    CGPoint position = [r locationInView:self.pageView];
    // Need to flip Y coordinate in order to match Core Graphics coordinate system.
    position.y = self.pageView.bounds.size.height - position.y;
    position = [self.renderManager convertedPoint:position
                       intoCoordinateSystemOfPage:self.page
                                      fitIntoRect:self.pageView.bounds];
    
    [self _addSquigglePoint:position];
    
    [self.pageView setNeedsDisplay];
}

- (void)_addSquigglePoint:(CGPoint)p
{
    if (!self.annotation)
    {
        self.annotation = [[SquiggleAnnotation alloc] init];
        self.annotation.position = p;
        [self.page.annotations addObject:self.annotation];
    }
    
    [self.annotation.points addObject:[NSValue valueWithCGPoint:CGPointMake(p.x - self.annotation.position.x, p.y - self.annotation.position.y)]];
}

@end