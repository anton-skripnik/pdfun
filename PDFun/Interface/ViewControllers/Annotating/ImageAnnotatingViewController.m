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

- (void)_barButtonItemTapped:(UIBarButtonItem *)item;
- (void)_handleSuccessfulGestureRecognitionBy:(UIGestureRecognizer *)r;

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
        for (NSUInteger i = IMAGE_NAME_START_INDEX; i <= IMAGE_NAME_END_INDEX; i++)
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
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSuccessfulGestureRecognitionBy:)];
    [self.pageView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSuccessfulGestureRecognitionBy:)];
    [self.pageView addGestureRecognizer:self.panGestureRecognizer];
}

- (void)cancel
{
    [self.page.annotations removeObject:self.annotation];
    [super cancel];
}

@end

#pragma mark - Private methods -

@implementation ImageAnnotatingViewController (Private)

- (void)_barButtonItemTapped:(UIBarButtonItem *)item
{
    self.annotation.image = item.image;
    [self.pageView setNeedsDisplay];
}

- (void)_handleSuccessfulGestureRecognitionBy:(UIGestureRecognizer *)r
{
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