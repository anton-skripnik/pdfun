//
//  PlainPDFDocument.m
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "PlainPDFDocument.h"
#import "Globals.h"

@interface PlainPDFDocument ()

@property (nonatomic, copy)             NSString*           path;
@property (nonatomic, assign)           CGPDFDocumentRef    CGPDFDocument;

@end

@implementation PlainPDFDocument

+ (instancetype)documentWithPath:(NSString *)path
{
    if ([path length] == 0)
    {
        DLog(@"Unable to create document with empty path.");
        return nil;
    }
    
    PlainPDFDocument* document = [[self alloc] init];
    document.path = path;
    
    return document;
}

- (void)dealloc
{
    [self close];
}

- (NSString *)name
{
    return [[self.path lastPathComponent] stringByDeletingPathExtension];
}

- (BOOL)open
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path])
    {
        DLog(@"Failed to find file at %@", self.path);
        return NO;
    }
    
    NSURL* URL = [NSURL fileURLWithPath:self.path];
    self.CGPDFDocument = CGPDFDocumentCreateWithURL((CFURLRef)URL);
    
    return self.CGPDFDocument != NULL;
}

- (void)close
{
    if (self.CGPDFDocument)
    {
        CGPDFDocumentRelease(self.CGPDFDocument), self.CGPDFDocument = NULL;
    }
}

@end
