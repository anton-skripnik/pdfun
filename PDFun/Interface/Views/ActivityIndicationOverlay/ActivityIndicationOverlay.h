//
//  ActivityIndicationOverlay.h
//  PDFun
//
//  Created by Anton Skripnik on 10/11/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import <UIKit/UIKit.h>

//
//  A view to display atop the app content when some long-time activity is going on.
//
@interface ActivityIndicationOverlay : UIView

@property (nonatomic, copy)     NSString*   text;

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithGenericText;

// -present... methods add the overlay as a subview to the parent view and mind the
// positioning.
- (void)presentOnTopOfView:(UIView *)parentView;
- (void)presentAnimatedOnTopOfView:(UIView *)parentView withCompletion:(void (^)())completion;
- (void)dismiss;
- (void)dismissAnimatedWithCompletion:(void (^)())completion;

@end
