//
//  PreviewViewController.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFDocument.h"

@interface PreviewViewController : UIViewController

@property (nonatomic, strong, readonly)     PDFDocument*    document;

- (instancetype)initWithDocument:(PDFDocument *)document;

@end
