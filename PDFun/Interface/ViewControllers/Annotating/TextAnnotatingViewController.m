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

#define TEXT_FIELD_WIDTH                            250
#define TEXT_FIELD_HEIGHT                           20
#define DEFAULT_ANNOTATION_TEXT                     @"<Placeholder>"

@interface TextAnnotatingViewController ()

@property (nonatomic, strong)       TextAnnotation*             annotation;
@property (nonatomic, strong)       UITapGestureRecognizer*     tapGestureRecognizer;
@property (nonatomic, strong)       UIPanGestureRecognizer*     panGestureRecognizer;
@property (nonatomic, strong)       UITextField*                textField;

@end

@interface TextAnnotatingViewController (UITextFieldDelegate)<UITextFieldDelegate> @end
@interface TextAnnotatingViewController (Private)

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r;
- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r;
- (void)_handleSuccessfulRecognitionBy:(UIGestureRecognizer *)r;

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
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT)];
    self.textField.layer.borderWidth = 0.5;
    self.textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textField.layer.cornerRadius = 3.0;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.placeholder = @"Enter something and then tap!";
    self.textField.delegate = self;
    UIBarButtonItem* textFieldBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.textField];
    UIBarButtonItem* leftFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* rightFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[ leftFlexibleItem, textFieldBarButtonItem, rightFlexibleItem ];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)cancel
{
    [[self.page annotations] removeObject:self.annotation];
    [super cancel];
}

@end

#pragma mark - UITextFieldDelegate methods -

@implementation TextAnnotatingViewController (UITextFieldDelegate)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
   
    if (self.annotation)
    {
        self.annotation.text = self.textField.text;
        [self.pageView setNeedsDisplay];
    }
    
    return YES;
}

@end

#pragma mark - Private methods -

@implementation TextAnnotatingViewController (Private)

- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r
{
    [self _handleSuccessfulRecognitionBy:r];
}

- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r
{
    if (r.state == UIGestureRecognizerStateBegan || r.state == UIGestureRecognizerStateChanged)
    {
        [self _handleSuccessfulRecognitionBy:r];
    }
}

- (void)_handleSuccessfulRecognitionBy:(UIGestureRecognizer *)r
{
    if (!self.annotation)
    {
        self.annotation = [[TextAnnotation alloc] init];
        self.annotation.text = self.textField.text;
        [self.page.annotations addObject:self.annotation];
    }
    
    CGPoint position = [r locationInView:self.pageView];
    // Need to flip Y coordinate in order to match Core Graphics coordinate system.
    position.y = self.pageView.bounds.size.height - position.y;
    position = [self.renderManager convertedPoint:position
                       intoCoordinateSystemOfPage:self.page
                                      fitIntoRect:self.pageView.bounds];
    
    self.annotation.position = position;
    
    [self.pageView setNeedsDisplay];
}

@end
