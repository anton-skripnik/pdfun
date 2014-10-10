//
//  AnnotatingViewController.m
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "AnnotatingViewController.h"
#import "AnnotatingViewController+Protected.h"
#import "Globals.h"
#import "PDFPage.h"
#import "PDFRenderManager.h"

#import "SquiggleAnnotatingViewController.h"
#import "TextAnnotatingViewController.h"
#import "ImageAnnotatingViewController.h"


#define VIEW_BACKGROUND_COLOR                           [UIColor whiteColor]
#define PAGE_BACKGROUND_VIEW_COLOR                      [UIColor lightGrayColor]


@interface AnnotatingViewController ()

@property (nonatomic, strong)       PDFPage*            page;
@property (nonatomic, weak)         PDFRenderManager*   renderManager;
@property (nonatomic, strong)       UIView*             backgroundView;
@property (nonatomic, strong)       AnnotatedPageView*  pageView;

@end

@implementation AnnotatingViewController

+ (NSArray *)annotatingControllerList
{
    return
    @[
        [SquiggleAnnotatingViewController class],
        [TextAnnotatingViewController class],
        [ImageAnnotatingViewController class],
    ];
}

+ (Class)annotationClass
{
    ENSURE_METHOD_IS_OVERRIDEN;
}

+ (NSString *)annotationTypeString
{
    ENSURE_METHOD_IS_OVERRIDEN;
}

- (instancetype)initWithPDFPage:(PDFPage *)page renderManager:(PDFRenderManager *)renderManager
{
    NSASSERT_NOT_NIL(page);
    NSASSERT_NOT_NIL(renderManager);
    
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        self.page = page;
        self.renderManager = renderManager;
    }
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.backgroundView];
    
    self.pageView = [[AnnotatedPageView alloc] initWithFrame:self.backgroundView.bounds];
    [self.backgroundView addSubview:self.pageView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    
    self.title = [[self class] annotationTypeString];
    
    [self.navigationController setToolbarHidden:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Accept"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(accept)];

    self.backgroundView.backgroundColor = PAGE_BACKGROUND_VIEW_COLOR;

    self.pageView.page = self.page;
    self.pageView.renderManager = self.renderManager;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat navbarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat toolbarHeight = self.navigationController.toolbar.bounds.size.height;
    
    // The size of view's area not obscured by any bars.
    CGSize contentSize = CGSizeZero;
    contentSize.width = self.view.bounds.size.width;
    contentSize.height = self.view.bounds.size.height - navbarHeight - statusBarHeight - toolbarHeight;
    
    CGRect backgroundViewFrame = CGRectZero;
    backgroundViewFrame.size = contentSize;
    backgroundViewFrame.origin.y = statusBarHeight + navbarHeight;
    self.backgroundView.frame = backgroundViewFrame;
    
    // Lay the background view out the way page's content fits the unobscured area.
    CGSize pageSize = self.page.mediaBoxRect.size;
    CGRect pageViewFrame = CGRectZero;
    if (pageSize.width > pageSize.height)
    {
        pageViewFrame.size.width = roundf(contentSize.width);
        pageViewFrame.size.height = roundf(pageViewFrame.size.width * (pageSize.height / pageSize.width));
    }
    else
    {
        pageViewFrame.size.height = roundf(contentSize.height);
        pageViewFrame.size.width = roundf(pageViewFrame.size.height * (pageSize.width / pageSize.height));
    }
    pageViewFrame.origin.x = roundf((contentSize.width - pageViewFrame.size.width) * 0.5f);
    pageViewFrame.origin.y = roundf((contentSize.height - pageViewFrame.size.height) * 0.5f);
    self.pageView.frame = pageViewFrame;
}

@end
