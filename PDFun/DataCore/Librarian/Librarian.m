//
//  Librarian.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "Librarian.h"
#import "Globals.h"

#import "PlainPDFDocument.h"
#import "EncryptedPDFDocument.h"

@interface Librarian ()

@property (nonatomic, strong)       dispatch_queue_t        queue;

@property (atomic, strong)          NSArray*                documents;

@end

@interface Librarian (Private)

- (NSArray *)_consumableDocumentPaths;
- (NSDictionary *)_consumableExtensionsToDocumentClassesMap;

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

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.queue = dispatch_queue_create(APP_SPECIFIC_ID_WITH_SUFFIX("librarianqueue"), DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    
    return self;
}

- (void)refreshDocumentsListWithCompletion:(LibrarianCompletionBlock)completion
{
    dispatch_async(self.queue, ^
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
        @"pdf" : [PlainPDFDocument class],
        @"epd" : [EncryptedPDFDocument class],  /* A custom extension. */
    };
}

@end