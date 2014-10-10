//
//  Librarian.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "Librarian.h"
#import "Globals.h"
#import "TemporaryStorageManager.h"
#import "Cryptor.h"
#import "NSFileManager+Utils.h"
#import "PDFRenderManager.h"

#import "PlainPDFDocument.h"
#import "EncryptedPDFDocument.h"


NSString* const LibrarianErrorDomain = @"LibrarianErrorDomain";


@interface Librarian ()

@property (atomic, strong)          NSArray*                documents;

@end

@interface Librarian (Private)

- (NSArray *)_consumableDocumentPaths;
- (NSDictionary *)_consumableExtensionsToDocumentClassesMap;
- (NSString *)_libraryPathForDocumentWithName:(NSString *)documentName withType:(NSString *)extension;

@end

@implementation Librarian

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static Librarian* staticInstance = nil;
    dispatch_once(&onceToken, ^
    {
        staticInstance = [[Librarian alloc] init];
    });
    
    return staticInstance;
}

- (void)refreshDocumentsListWithCompletion:(LibrarianCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSFileManager*  fileManager = [NSFileManager defaultManager];
        
        NSArray*        lookupPaths = [self _consumableDocumentPaths];
        NSDictionary*   lookupExtensionToClassesMap = [self _consumableExtensionsToDocumentClassesMap];
        
        NSMutableArray* documents = [NSMutableArray array];
        [lookupPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            @autoreleasepool
            {
                NSASSERT_OF_CLASS(obj, NSString);
                NSString* path = obj;
                NSError* __autoreleasing error = nil;
                NSArray* pathContents = [fileManager contentsOfDirectoryAtPath:path error:&error];
                if (!pathContents)
                {
                    DLog(@"Error getting contents of directory %@: %@", path, error);
                    return;
                }
                
                [pathContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                {
                    @autoreleasepool
                    {
                        NSASSERT_OF_CLASS(obj, NSString);
                        NSString* potentialDocumentFileName = obj;
                        
                        if ([potentialDocumentFileName hasPrefix:@"."])
                        {
                            // Skip hidden files along with . and ..
                            return;
                        }
                        
                        NSString* extension = [[potentialDocumentFileName pathExtension] lowercaseString];
                        if (lookupExtensionToClassesMap[extension] != nil)
                        {
                            // A file with supported extension found.
                            NSString* fullDocumentPath = [path stringByAppendingPathComponent:potentialDocumentFileName];
                            
                            Class<PDFDocumentProtocol> pdfDocumentClass = lookupExtensionToClassesMap[extension];
                            PDFDocument* document = [pdfDocumentClass documentWithPath:fullDocumentPath];
                            if (document)
                            {
                                [documents addObject:document];
                            }
                        }
                    }
                }];
            }
        }];
        
        self.documents = documents;
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completion(nil);
            });
        }
    });
}

- (void)addToLibraryEncryptedCopyOfDocument:(NSObject<PDFDocumentProtocol> *)document
                                   withName:(NSString *)newDocumentName
                                   password:(NSString *)password
                                 completion:(LibrarianCompletionBlock)completion
{
    NSASSERT_NOT_NIL(document);
    NSASSERT_NOT_NIL(newDocumentName);
    NSASSERT_NOT_NIL(password);
    
    if (document.CGPDFDocument == NULL)
    {
        DLog(@"Cannot copy a document that hasn't been opened yet!");
        NSError* unopenDocumentError = [NSError errorWithDomain:LibrarianErrorDomain code:LibrarianErrorCopyingUnopenDocument userInfo:@{ NSLocalizedDescriptionKey: @"Unable to copy a document not open before!" }];
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completion(unopenDocumentError);
            });
        }
        
        return;
    }
    
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString* renderedTemporaryPDFPath = [[TemporaryStorageManager sharedManager] pathForNamePrefix:newDocumentName ofType:[PlainPDFDocument extension]];
    NSURL* renderedTemporaryPDFURL = [NSURL fileURLWithPath:renderedTemporaryPDFPath];
    PDFRenderManager* renderer = [[PDFRenderManager alloc] init];
    [renderer renderDocument:document saveToURL:renderedTemporaryPDFURL];
    
    NSString* temporaryBinaryPath = [[renderedTemporaryPDFPath stringByDeletingPathExtension] stringByAppendingPathExtension:[EncryptedPDFDocument extension]];
    
    Cryptor* __block cryptor = [[Cryptor alloc] init];
    [cryptor encryptSourcePDFAt:renderedTemporaryPDFPath
                   intoBinaryAt:temporaryBinaryPath
                   withPassword:password
                     completion:^(NSError *error)
    {
        [fileManager removeItemAtPath:renderedTemporaryPDFPath error:nil];
        
        if (error)
        {
            [fileManager removeItemAtPath:temporaryBinaryPath error:nil];
            if (completion)
            {
                completion(error);
            }
        }
        else
        {
            NSString* destinationBinaryPath = [self _libraryPathForDocumentWithName:newDocumentName withType:[EncryptedPDFDocument extension]];
            NSError* __autoreleasing binaryMovingError = nil;
            if ([fileManager moveItemAtPath:temporaryBinaryPath possiblyReplacingItemAtPath:destinationBinaryPath error:&binaryMovingError])
            {
                if (completion)
                {
                    completion(nil);
                }
            }
            else
            {
                DLog(@"Failed to move temporary binary %@ to %@. Error %@", temporaryBinaryPath, destinationBinaryPath, binaryMovingError);
                if (completion)
                {
                    completion(binaryMovingError);
                }
                [fileManager removeItemAtPath:temporaryBinaryPath error:nil];
            }
        }
        
        cryptor = nil;
    }];
}

@end

#pragma mark - Private methods -

@implementation Librarian (Private)

- (NSArray *)_consumableDocumentPaths
{
    NSURL* documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString* documentsDirectoryPath = [documentsDirectoryURL path];
    
    NSString* bundledPDFsDirectoryPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"BundledPDFs"];

    return
    @[
        documentsDirectoryPath,
        bundledPDFsDirectoryPath,
    ];
}

- (NSDictionary *)_consumableExtensionsToDocumentClassesMap
{
    return
    @{
        [PlainPDFDocument extension] : [PlainPDFDocument class],
        [EncryptedPDFDocument extension] : [EncryptedPDFDocument class],  
    };
}

- (NSString *)_libraryPathForDocumentWithName:(NSString *)documentName withType:(NSString *)extension
{
    NSURL* documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString* documentsDirectoryPath = [documentsDirectoryURL path];
    
    return [[documentsDirectoryPath stringByAppendingPathComponent:documentName] stringByAppendingPathExtension:extension];
}

@end