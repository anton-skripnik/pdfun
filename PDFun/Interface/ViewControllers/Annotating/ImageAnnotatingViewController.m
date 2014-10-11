//
//  ImageAnnotatingViewController.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "ImageAnnotatingViewController.h"
#import "AnnotatingViewController+Protected.h"
#import "Globals.h"
#import "ImageAnnotation.h"

#define IMAGE_NAME_PATTERN      @"Image%u"
#define IMAGE_NAME_START_INDEX  1
#define IMAGE_NAME_END_INDEX    5

@interface ImageAnnotatingViewController ()

@property (nonatomic, strong)           ImageAnnotation*            annotation;
@property (nonatomic, strong)           UITapGestureRecognizer*     tapGestureRecognizer;
@property (nonatomic, strong)           UIPanGestureRecognizer*     panGestureRecognizer;
@property (nonatomic, strong)           NSArray*                    annotationImages;

@end

@interface ImageAnnotatingViewController (Private)

- (void)_updateAnnotationPositionWithRecognizedPosition:(CGPoint)recognizedPosition;
- (void)_updateAnnotationImage:(UIImage *)image;

- (void)_barButtonItemTapped:(UIBarButtonItem *)item;
- (void)_tapGestureRecognizedBy:(UITapGestureRecognizer *)r;
- (void)_panGestureRecognizedBy:(UIPanGestureRecognizer *)r;

@end

@implementation ImageAnnotatingViewController

+ (Class)annotationClass
{
    return [ImageAnnotation class];
}

+ (NSString *)annotationTypeString
{
    return @"Image";
}

- (instancetype)initWithPDFPage:(PDFPage *)page renderManager:(PDFRenderManager *)renderManager
{
    if ((self = [super initWithPDFPage:page renderManager:renderManager]))
    {
        NSMutableArray* images = [NSMutableArray array];
        for (unsigned int i = IMAGE_NAME_START_INDEX; i <= IMAGE_NAME_END_INDEX; i++)
        {
            NSString* imageName = [NSString stringWithFormat:IMAGE_NAME_PATTERN, i];
            UIImage* image = [UIImage imageNamed:imageName];
            if (image)
            {
                [images addObject:image];
            }
        }
        self.annotationImages = images;
        self.annotation = [[ImageAnnotation alloc] init];
        self.annotation.image = self.annotationImages.firstObject;
        [self.page.annotations addObject:self.annotation];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray* toolbarItems = [NSMutableArray array];
    for (NSUInteger i = IMAGE_NAME_START_INDEX; i <= IMAGE_NAME_END_INDEX; i++)
    {
        NSUInteger imageIndex = i - IMAGE_NAME_START_INDEX;
        UIImage* correspondingImage = self.annotationImages[imageIndex];
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithImage:correspondingImage
                                                                 style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(_barButtonItemTapped:)];
        item.tag = imageIndex;
        
        UIBarButtonItem* leftSpacingFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolbarItems addObject:leftSpacingFlexibleItem];
        [toolbarItems addObject:item];
    }
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    self.toolbarItems = toolbarItems;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognizedBy:)];
    [self.pageView addGestureRecognizer:self.panGestureRecognizer];
}

- (Annotation *)editedAnnotation
{
    return self.annotation;
}

@end

#pragma mark - Private methods -

@implementation ImageAnnotatingViewController (Private)

- (void)_updateAnnotationPositionWithRecognizedPosition:(CGPoint)recognizedPosition
{
    CGPoint newAnnotationPosition = CGPointZero;
    newAnnotationPosition.x = recognizedPosition.x;
    // Need to flip Y coordinate in order to match Core Graphics coordinate system.
    newAnnotationPosition.y = self.pageView.bounds.size.height - recognizedPosition.y;
    newAnnotationPosition = [self.renderManager convertedPoint:newAnnotationPosition
                                    intoCoordinateSystemOfPage:self.page
                                                   fitIntoRect:self.pageView.bounds];
    
    self.annotation.position = newAnnotationPosition;
    [self.pageView setNeedsDisplay];
}

- (void)_updateAnnotationImage:(UIImage *)image
{
    self.annotation.image = image;
    [self.pageView setNeedsDisplay];
}

- (void)_barButtonItemTapped:(UIBarButtonItem *)item
{
    [self _updateAnnotationImage:self.annotationImages[item.tag]];
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

@end