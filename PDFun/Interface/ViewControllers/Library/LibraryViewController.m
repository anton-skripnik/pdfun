//
//  LibraryViewController.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "LibraryViewController.h"
#import "Globals.h"
#import "Librarian.h"

#import "PDFDocument.h"
#import "PlainPDFDocument.h"
#import "EncryptedPDFDocument.h"

#define TITLE                                               @"Library"
#define LIBRARY_ITEM_CELL_IDENTIFIER                        CELL_ID_WITH_SUFFIX("library")

#define VIEW_BACKGROUND_COLOR                               [UIColor whiteColor]

@interface LibraryViewController ()

@property (nonatomic, strong)   UITableView*                itemsTableView;

@end
@interface LibraryViewController (UITableViewDelegate)<UITableViewDelegate> @end
@interface LibraryViewController (UITableViewDataSource)<UITableViewDataSource> @end
@interface LibraryViewController (Private)

@end

#pragma mark - Public methods -

@implementation LibraryViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.itemsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.itemsTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = TITLE;
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    
    self.itemsTableView.hidden = YES;
    self.itemsTableView.delegate = self;
    self.itemsTableView.dataSource = self;
    self.itemsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.itemsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LIBRARY_ITEM_CELL_IDENTIFIER];
    
    [[Librarian sharedInstance] refreshDocumentsListWithCompletion:^(NSError *error)
    {
        if (!error)
        {
            self.itemsTableView.hidden = NO;
            [self.itemsTableView reloadData];
        }
    }];
}

@end

#pragma mark - UITableViewDelegate methods -

@implementation LibraryViewController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#warning TEST CODE. REMOVE IT!
    PDFDocument* document = [[[Librarian sharedInstance] documents] objectAtIndex:indexPath.row];
    if ([document isKindOfClass:[EncryptedPDFDocument class]])
    {
        [(EncryptedPDFDocument *)document setPassword:@"Dummy_password"];
    }
    
    DLog(@"Opening document...");
    [document openWithCompletion:^(BOOL succeeded)
    {
        DLog(@"Done opening document. %s", succeeded ? "success" : "failed");
        if (succeeded)
        {
            DLog(@"Copying an encrypted version of the document to the Library.");
            [[Librarian sharedInstance] addToLibraryEncryptedCopyOfDocument:document
                                                                   withName:[document.name stringByAppendingString:@".enc"]
                                                                   password:@"Dummy_password"
                                                                 completion:^(NSError *error)
            {
                DLog(@"Done encrypting and copying. %@", error ? error : @"success");
                [document close];
                DLog(@"Reloading library data.");
                [[Librarian sharedInstance] refreshDocumentsListWithCompletion:^(NSError *error)
                {
                    DLog(@"Done reloading library. %@", error ? error : @"success");
                    [tableView reloadData];
                }];
            }];
        }
    }];
#warning END OF TEST CODE. REMOVE UP TO THIS POINT.

}

@end

#pragma mark - UITableViewDataSource methods -

@implementation LibraryViewController (UITableViewDataSource)

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Librarian sharedInstance] documents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* itemCell = [tableView dequeueReusableCellWithIdentifier:LIBRARY_ITEM_CELL_IDENTIFIER
                                                                forIndexPath:indexPath];
    itemCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PDFDocument* document = [[[Librarian sharedInstance] documents] objectAtIndex:indexPath.row];
    itemCell.textLabel.text = document.name;
    
    return itemCell;
}

@end

#pragma mark - Private methods -

@implementation LibraryViewController (Private)

@end