//
//  AnnotatingViewController.h
//  PDFun
//
//  Created by Anton Skripnik on 10/9/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFPage;
@class PDFRenderManager;

@protocol AnnotatingViewControllerDelegate;

//
//  Abstract base class for controllers managing annotation adding.
//  Supplies a list of all available concrete subclasses.
//
@interface AnnotatingViewController : UIViewController

@property (nonatomic, strong, readonly) PDFPage*                                page;
@property (nonatomic, weak, readonly)   PDFRenderManager*                       renderManager;
@property (nonatomic, weak)             id<AnnotatingViewControllerDelegate>    delegate;

// Returns list of subclasses.
+ (NSArray *)annotatingControllerList;

// Subclasses will override and return the class of associated annotation type.
+ (Class)annotationClass;
// Subclasses will override and return the string identifier of associated annotation type.
+ (NSString *)annotationTypeString;

- (instancetype)initWithPDFPage:(PDFPage *)page renderManager:(PDFRenderManager *)renderManager;

@end



@protocol AnnotatingViewControllerDelegate <NSObject>

@required
- (void)annotatingViewControllerRequestsDimsissing:(AnnotatingViewController *)controller;

@end