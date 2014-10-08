//
//  Librarian.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFDocument.h"


// A generic completion block type.
// CONVENTION: error == nil means everything went well.
typedef void(^LibrarianCompletionBlock)(NSError* error);

extern NSString* const LibrarianErrorDomain;
NS_ENUM(NSUInteger, LibrarianError)
{
    LibrarianErrorUnknown,
    LibrarianErrorCopyingUnopenDocument,
};


//
//  The class to handle document on-disk storage operations.
//
@interface Librarian : NSObject

// List of documents fetched during the latest refresh.
@property (nonatomic, strong, readonly)     NSArray*            documents;  // of PDFDocuments

// Yep, a singleton.
+ (instancetype)sharedInstance;

// Builds up a list of documents from files in bunch of places and updates self.documents.
// Calls completion on main thread when is done.
- (void)refreshDocumentsListWithCompletion:(LibrarianCompletionBlock)completion;

// Given a PDF document (no matter if encrypted or not) creates a copy of the document in the storage,
// names it using newDocumentName and encrypts the data using password. At the end of operation
// invokes completion on the main thread.
- (void)addToLibraryEncryptedCopyOfDocument:(PDFDocument *)document withName:(NSString *)newDocumentName password:(NSString *)password completion:(LibrarianCompletionBlock)completion;

@end
