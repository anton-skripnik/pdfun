//
//  PreviewCollectionViewCell.h
//  PDFun
//
//  Created by Anton Skripnik on 10/8/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFRenderManager;
@class PDFPage;

@interface PageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)   PDFPage*            page;
@property (nonatomic, strong)   PDFRenderManager*   renderManager;

@end
