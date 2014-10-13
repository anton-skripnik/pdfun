//
//  TextAnnotatingViewController.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "TextAnnotatingViewController.h"
#import "AnnotatingViewController+Protected.h"
#import "Globals.h"
#import "TextAnnotation.h"

#define HINT_TEXT               @"Long press to set text. Drag or tap to move."
#define HINT_TEXT_COLOR         [UIColor lightGrayColor]
#define HINT_FONT               [UIFont systemFontOfSize:14.0]

@interface TextAnnotatingViewController ()

@property (nonatomic, strong)       TextAnnotation*                 annotation;
@property (nonatomic, strong)       UITapGestureRecognizer*         tapGestureRecognizer;
@property (nonatomic, strong)       UIPanGestureRecognizer*         panGestureRecognizer;
@property (nonatomic, strong)       UILongPressGestureRecognizer*   longPressGestureRecognizer;

@end

@interface TextAnnotatingViewController (UIAlertViewDelegate)<UIAlertViewDelegate> @end
@interface TextAnnotatingViewController (Private)

- (void)_spawnAnnotationIfNecessary;

- (void)_updateAnnotationPositionWithRecognizedPosition:(CGPoint)recognizedPosition;
- (void)_updateAnnotationText:(NSString *)annotationText;

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r;
- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r;

- (void)_initiateAnnotationTextInput;
- (void)_longPressGestureRecognizedBy:(UILongPressGestureRecognizer *)r;

@end

@implementation TextAnnotatingViewController

+ (Class)annotationClass
{
    return [TextAnnotation class];
}

+ (NSString *)annotationTypeString
{
    return @"Text";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* leftFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UILabel* hintLabel = [[UILabel alloc] init];
    hintLabel.font = HINT_FONT;
    hintLabel.text = HINT_TEXT;
    hintLabel.textColor = HINT_TEXT_COLOR;
    [hintLabel sizeToFit];
    UIBarButtonItem* hintBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hintLabel];
    UIBarButtonItem* rightFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[ leftFlexibleItem, hintBarButtonItem, rightFlexibleItem ];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.panGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (Annotation *)editedAnnotation
{
    return self.annotation;
}

@end

#pragma mark - UIAlertViewDelegate -

@implementation TextAnnotatingViewController (UIAlertViewDelegate)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self _updateAnnotationText:[[alertView textFieldAtIndex:0] text]];
    }
}

@end

#pragma mark - Private methods -

@implementation TextAnnotatingViewController (Private)

- (void)_spawnAnnotationIfNecessary
{
    if (!self.annotation)
    {
        self.annotation = [[TextAnnotation alloc] init];
        self.pageView.annotation = self.annotation;
    }
}

- (void)_updateAnnotationPositionWithRecognizedPosition:(CGPoint)recognizedPosition
{
    [self _spawnAnnotationIfNecessary];
    
    CGPoint newAnnotationPosition = CGPointZero;
    newAnnotationPosition.x = recognizedPosition.x;
    // Need to flip Y coordinate in order to match Core Graphics coordinate system.
    newAnnotationPosition.y = self.pageView.bounds.size.height - recognizedPosition.y;
    newAnnotationPosition = [self.renderManager convertedPoint:newAnnotationPosition
                                    intoCoordinateSystemOfPage:self.page
                                                   fitIntoRect:self.pageView.bounds];
    
    self.annotation.position = newAnnotationPosition;
    [self.pageView updateAnnotation];
}

- (void)_updateAnnotationText:(NSString *)annotationText
{
    [self _spawnAnnotationIfNecessary];
    self.annotation.text = annotationText;
    [self.pageView updateAnnotation];
}

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r
{
    [self _updateAnnotationPositionWithRecognizedPosition:[r locationInView:self.pageView]];
}

- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r
{
    if (r.state == UIGestureRecognizerStateBegan || r.state == UIGestureRecognizerStateChanged)
    {
        [self _updateAnnotationPositionWithRecognizedPosition:[r locationInView:self.pageView]];
    }
}

- (void)_initiateAnnotationTextInput
{
    // Displaying the alert takes a bunch of time, especially for the first time.
    // Apparently, it has something to do with low performance operation on the main thread (wild guess: the rendering)
    // TODO: Check if it's still slow after redrering optimizations and, if so, consider not using alert view. 

    UIAlertView* setAnnotationTextAlert = [[UIAlertView alloc] initWithTitle:@"Annotation text" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    setAnnotationTextAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [setAnnotationTextAlert show];
}

- (void)_longPressGestureRecognizedBy:(UILongPressGestureRecognizer *)r
{
    if (r.state == UIGestureRecognizerStateBegan)
    {
        [self _initiateAnnotationTextInput];
    }
}


@end
