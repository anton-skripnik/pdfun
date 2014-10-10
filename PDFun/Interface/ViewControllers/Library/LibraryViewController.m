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

#import "PreviewViewController.h"


#define TITLE                                               @"Library"
#define LIBRARY_ITEM_CELL_IDENTIFIER                        CELL_ID_WITH_SUFFIX("library")

#define VIEW_BACKGROUND_COLOR                               [UIColor whiteColor]


@interface LibraryViewController ()

@property (nonatomic, strong)   PDFDocument*                documentToOpen;
@property (nonatomic, strong)   UITableView*                itemsTableView;

@end
@interface LibraryViewController (UITableViewDelegate)<UITableViewDelegate> @end
@interface LibraryViewController (UITableViewDataSource)<UITableViewDataSource> @end
@interface LibraryViewController (UIAlertViewDelegate)<UIAlertViewDelegate> @end
@interface LibraryViewController (Private)

- (void)_performOpeningDocument:(PDFDocument *)document;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // When we return from a preview controller, we want the toolbar hidden.
    [self.navigationController setToolbarHidden:YES animated:YES];
}

@end

#pragma mark - UITableViewDelegate methods -

@implementation LibraryViewController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PDFDocument* document = [[[Librarian sharedInstance] documents] objectAtIndex:indexPath.row];
    if ([[document class] requiresPassword])
    {
        self.documentToOpen = document;
        UIAlertView* requestPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"Decryption" message:@"Provide the password the document was encrypted with." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Decrypt", nil];
        requestPasswordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [requestPasswordAlertView show];
        return;
    }
    
    [self _performOpeningDocument:document];
}

@end

#pragma mark - UITableViewDataSource methods -

@implementation LibraryViewController (UITableViewDataSource)

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
    
    if ([[document class] requiresPassword])
    {
        itemCell.textLabel.font = [UIFont boldSystemFontOfSize:itemCell.textLabel.font.pointSize];
    }
    else
    {
        itemCell.textLabel.font = [UIFont systemFontOfSize:itemCell.textLabel.font.pointSize];
    }
    
    return itemCell;
}

@end

#pragma mark - Private methods -

@implementation LibraryViewController (Private)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString* password = [alertView textFieldAtIndex:0].text;
        if ([password length] >= MINIMAL_PASSWORD_LENGTH)
        {
            if (self.documentToOpen)
            {
                NSASSERT_OF_CLASS(self.documentToOpen, EncryptedPDFDocument);
                EncryptedPDFDocument* encryptedDocumentToOpen = (EncryptedPDFDocument *)self.documentToOpen;
                encryptedDocumentToOpen.password = password;
                [self _performOpeningDocument:encryptedDocumentToOpen];
            }
        }
        else
        {
            UIAlertView* badPasswordAlertView = [[UIAlertView alloc] initWithTitle:@"Bad Password!" message:[NSString stringWithFormat:@"Cannot accept the password less than %u characters long.", MINIMAL_PASSWORD_LENGTH] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [badPasswordAlertView show];
        }
        
    }
}

- (void)_performOpeningDocument:(NSObject<PDFDocumentProtocol> *)document
{
    [document openWithCompletion:^(BOOL succeeded)
    {
        if (!succeeded)
        {
            UIAlertView* failedAlertView = [[UIAlertView alloc] initWithTitle:@"Failed!" message:@"Couldn't open the document. Sorry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [failedAlertView show];
        }
        else
        {
            PreviewViewController* previewController = [[PreviewViewController alloc] initWithDocument:document];
            [self.navigationController pushViewController:previewController animated:YES];
        }
    }];
}

@end