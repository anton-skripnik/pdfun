//
//  PreviewViewController.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PreviewViewController.h"
#import "AnnotatingViewController.h"
#import "PageCollectionViewCell.h"
#import "ActivityIndicationOverlay.h"

#import "Globals.h"
#import "PDFRenderManager.h"
#import "Librarian.h"

#define VIEW_BACKGROUND_COLOR                       [UIColor whiteColor]
#define COLLECITON_VIEW_CELL_ID                     CELL_ID_WITH_SUFFIX("pagecollectionview")
#define COLLECTION_VIEW_BACKGROUND_COLOR            [UIColor lightGrayColor]

@interface PreviewViewController ()

@property (nonatomic, strong)           PDFDocument*                document;
@property (nonatomic, strong)           PDFRenderManager*           renderManager;

@property (nonatomic, strong)           UICollectionView*           pagesCollectionView;
@property (nonatomic, strong)           UICollectionViewFlowLayout* pagesCollectionViewLayout;

@end

@interface PreviewViewController (UICollectionViewDataSource)<UICollectionViewDataSource> @end
@interface PreviewViewController (UICollectionViewDelegateFlowLayout)<UICollectionViewDelegateFlowLayout> @end
@interface PreviewViewController (UIActionSheetDelegate)<UIActionSheetDelegate> @end
@interface PreviewViewController (UIAlertViewDelegate)<UIAlertViewDelegate> @end
@interface PreviewViewController (AnnotatingViewControllerDelegate)<AnnotatingViewControllerDelegate> @end
@interface PreviewViewController (Private)

- (void)_annotateBarButtonItemTapped:(UIBarButtonItem *)barButtonItem;
- (void)_saveBarButtonItemTapped;

- (void)_encryptAndStoreDocumentCopyWithPassword:(NSString *)password;

- (CGSize)_sizeOfCollectionViewItemForPageWithIndex:(NSUInteger)pageIndex;

@end


#pragma mark - Public methods -

@implementation PreviewViewController

- (instancetype)initWithDocument:(NSObject<PDFDocumentProtocol> *)document
{
    NSAssert(document.CGPDFDocument != NULL, @"Only open document allowed!");
    
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        self.document = document;
        self.renderManager = [[PDFRenderManager alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [self.document close];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.pagesCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.pagesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.pagesCollectionViewLayout];
    
    [self.view addSubview:self.pagesCollectionView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.document.name;
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setToolbarHidden:NO];
    
    UIBarButtonItem* annotateBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Annotate"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(_annotateBarButtonItemTapped:)];
    UIBarButtonItem* saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(_saveBarButtonItemTapped)];
    UIBarButtonItem* flexibleSpacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                         target:nil
                                                                                         action:nil];
    self.toolbarItems = @[ annotateBarButtonItem, flexibleSpacingItem, saveBarButtonItem ];
    
    
    self.pagesCollectionView.delegate = self;
    self.pagesCollectionView.dataSource = self;
    self.pagesCollectionView.pagingEnabled = YES;
    self.pagesCollectionView.backgroundColor = COLLECTION_VIEW_BACKGROUND_COLOR;
    [self.pagesCollectionView registerClass:[PageCollectionViewCell class]
                 forCellWithReuseIdentifier:COLLECITON_VIEW_CELL_ID];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Lay the collection view out the way it occupies all unobscured area of the screen (not underlaping
    // navbar, status bar and toolbar). This way all the page will fit single screen and pagination will work neatly.
    
    CGFloat navbarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat toolbarHeight = self.navigationController.toolbar.bounds.size.height;
    
    CGRect pagesCollectionViewFrame = CGRectZero;
    pagesCollectionViewFrame.origin.x = 0;
    pagesCollectionViewFrame.origin.y = navbarHeight + statusBarHeight;
    pagesCollectionViewFrame.size.width = self.view.bounds.size.width;
    pagesCollectionViewFrame.size.height = self.view.bounds.size.height - pagesCollectionViewFrame.origin.y - toolbarHeight;
    self.pagesCollectionView.frame = pagesCollectionViewFrame;
}

@end

#pragma mark - UICollectionViewDataSource methods -

@implementation PreviewViewController (UICollectionViewDataSource)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return CGPDFDocumentGetNumberOfPages(self.document.CGPDFDocument);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* dequeuedCell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECITON_VIEW_CELL_ID forIndexPath:indexPath];
    NSASSERT_OF_CLASS(dequeuedCell, PageCollectionViewCell);
    
    NSInteger itemIndex = indexPath.item;
    NSAssert(itemIndex >= 0 && itemIndex < self.document.pages.count, @"Item index %d out of expected bounds.", itemIndex);
    
    PageCollectionViewCell* pageCell = (PageCollectionViewCell *)dequeuedCell;
    pageCell.page = self.document.pages[itemIndex];
    pageCell.renderManager = self.renderManager;
    
    return pageCell;
}

@end

#pragma mark - UICollectionViewDelegateFlowLayout methods -

@implementation PreviewViewController (UICollectionViewDelegateFlowLayout)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemIndex = indexPath.item;
    return [self _sizeOfCollectionViewItemForPageWithIndex:itemIndex];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end

#pragma mark - UIActionSheetDelegate methods -

@implementation PreviewViewController (UIActionSheetDelegate)

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        CGPoint centerPointInSelfView = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
        CGPoint centerPointInCollectionView = [self.pagesCollectionView convertPoint:centerPointInSelfView fromView:self.view];
        NSIndexPath* middleScreenElementIndexPath = [self.pagesCollectionView indexPathForItemAtPoint:centerPointInCollectionView];
        PDFPage* page = self.document.pages[middleScreenElementIndexPath.item];
    
        NSArray* availableAnnotatingControllers = [[AnnotatingViewController class] annotatingControllerList];
        Class correspondingAnnotatingControllerClass = availableAnnotatingControllers[buttonIndex];
        AnnotatingViewController* correspondingAnnotatingController = [[correspondingAnnotatingControllerClass alloc] initWithPDFPage:page renderManager:self.renderManager];
        correspondingAnnotatingController.delegate = self;
        
        // Place the annotating controller inside a navigation controller in order to have a navbar and toolbar
        // for free. 
        UINavigationController* containingNavigationController = [[UINavigationController alloc] initWithRootViewController:correspondingAnnotatingController];
        [self presentViewController:containingNavigationController animated:YES completion:nil];
    }
}

@end

#pragma mark - UIAlertViewDelegate methods -

@implementation PreviewViewController (UIAlertViewDelegate)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString* password = [[alertView textFieldAtIndex:0] text];
        if ([password length] >= MINIMAL_PASSWORD_LENGTH)
        {
            [self _encryptAndStoreDocumentCopyWithPassword:password];
        }
        else
        {
            UIAlertView* badPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"Bad Password!" message:[NSString stringWithFormat:@"Cannot accept a password less than %u characters long.", MINIMAL_PASSWORD_LENGTH] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [badPasswordAlertView show];
        }
    }
}

@end

#pragma mark - AnnotatingViewControllerDelegate methods -

@implementation PreviewViewController (AnnotatingViewControllerDelegate)

- (void)annotatingViewControllerRequestsDimsissing:(AnnotatingViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // Force visible page's repaint.
    NSArray* visiblePages = [self.pagesCollectionView visibleCells];
    [visiblePages makeObjectsPerformSelector:@selector(refresh)];
}

@end

#pragma mark - Private methods -

@implementation PreviewViewController (Private)

- (void)_annotateBarButtonItemTapped:(UIBarButtonItem *)barButtonItem
{
    NSArray* availableAnnotatingControllers = [[AnnotatingViewController class] annotatingControllerList];

    UIActionSheet* annotateActionSheet = [[UIActionSheet alloc] init];
    annotateActionSheet.delegate = self;
    annotateActionSheet.title = @"Choose annotation type";
    [availableAnnotatingControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj respondsToSelector:@selector(annotationTypeString)])
        {
            [annotateActionSheet addButtonWithTitle:[obj annotationTypeString]];
        }
    }];
    [annotateActionSheet addButtonWithTitle:@"Cancel"];
    annotateActionSheet.cancelButtonIndex = availableAnnotatingControllers.count;
    
    [annotateActionSheet showFromBarButtonItem:barButtonItem animated:YES];
}

- (void)_saveBarButtonItemTapped
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Encrypting" message:@"Choose a good password!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Encrypt", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)_encryptAndStoreDocumentCopyWithPassword:(NSString *)password
{
    ActivityIndicationOverlay* activityIndicationOverlay = [[ActivityIndicationOverlay alloc] initWithText:@"Saving..."];
    [activityIndicationOverlay presentAnimatedOnTopOfView:self.view withCompletion:NULL];

    // TODO: Consider letting user specify the name of new document.
    NSString* encryptedDocumentName = [self.document.name stringByAppendingString:@".enc"];

    // TODO: Consider possible overwriting.
    Librarian* librarian = [Librarian sharedInstance];
    [librarian addToLibraryEncryptedCopyOfDocument:self.document
                                          withName:encryptedDocumentName
                                          password:password
                                        completion:^(NSError *error)
    {
        if (error)
        {
            UIAlertView* failedToCreateAlert = [[UIAlertView alloc] initWithTitle:@"Failed!" message:@"Couldn't save the document. Please try once again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [failedToCreateAlert show];
        }
        else
        {
            UIAlertView* successAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"An encrypted copy of the document has been added to the Library." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [successAlert show];
        }
        
        [activityIndicationOverlay dismissAnimatedWithCompletion:NULL];
    }];
}

- (CGSize)_sizeOfCollectionViewItemForPageWithIndex:(NSUInteger)pageIndex
{
    NSAssert(pageIndex >= 0 && pageIndex < self.document.pages.count, @"Page index %d out of expected bounds.", pageIndex);
    PDFPage* page = self.document.pages[pageIndex];
    CGRect pageMediaBoxRect = page.mediaBoxRect;
    CGSize pageSize = pageMediaBoxRect.size;
    
    CGSize itemSize = CGSizeZero;
    if (pageSize.width > pageSize.height)
    {
        itemSize.width = roundf(self.pagesCollectionView.bounds.size.width);
        itemSize.height = roundf(itemSize.width * (pageSize.height / pageSize.width));
    }
    else
    {
        itemSize.height = roundf(self.pagesCollectionView.bounds.size.height);
        itemSize.width = roundf(itemSize.height * (pageSize.width / pageSize.height));
    }
    
    return itemSize;
}

@end