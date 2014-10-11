//
//  ActivityIndicationOverlay.m
//  PDFun
//
//  Created by Anton Skripnik on 10/11/14.
//  Copyright (c) 2014 DiddlyDoo. All rights reserved.
//

#import "ActivityIndicationOverlay.h"
#import "Globals.h"

#define ANIMATION_DURATION                      0.33

#define GENERIC_TEXT                            @"Doing stuff. Hold on..."

#define BEZEL_BACKGROUND_COLOR                  [UIColor colorWithWhite:0.0 alpha:0.8]
#define BEZEL_CORNER_RADIUS                     5
#define BEZEL_TOP_PADDING                       20
#define BEZEL_BOTTOM_PADDING                    20
#define BEZEL_LEFT_PADDING                      20
#define BEZEL_RIGHT_PADDING                     20
#define BEZEL_MIN_WIDTH                         80

#define ACTIVITY_INDICATOR_SIZE                 20

#define ACTIVITY_INDICATOR_TO_TEXT_LABEL_SPACE  10

#define TEXT_LABEL_FONT                         [UIFont boldSystemFontOfSize:18.0]
#define TEXT_LABEL_TEXT_COLOR                   [UIColor whiteColor]

@interface ActivityIndicationOverlay ()

@property (nonatomic, strong)       UIView*                     bezelContainerView;
@property (nonatomic, strong)       UIActivityIndicatorView*    activityIndicator;
@property (nonatomic, strong)       UILabel*                    textLabel;

@end

@implementation ActivityIndicationOverlay

- (instancetype)initWithText:(NSString *)text
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.bezelContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bezelContainerView.backgroundColor =  BEZEL_BACKGROUND_COLOR;
        self.bezelContainerView.layer.cornerRadius = BEZEL_CORNER_RADIUS;
        [self addSubview:self.bezelContainerView];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.bezelContainerView addSubview:self.activityIndicator];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.font = TEXT_LABEL_FONT;
        self.textLabel.text = text;
        self.textLabel.textColor = TEXT_LABEL_TEXT_COLOR;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self.bezelContainerView addSubview:self.textLabel];
    }
    
    return self;
}

- (instancetype)initWithGenericText
{
    return [self initWithText:GENERIC_TEXT];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize maxTextLabelSize = CGSizeZero;
    maxTextLabelSize.width = self.bounds.size.width - BEZEL_LEFT_PADDING - BEZEL_RIGHT_PADDING;
    maxTextLabelSize.height = CGFLOAT_MAX;
    CGSize textLabelSize = [self.textLabel sizeThatFits:maxTextLabelSize];
    CGFloat bezelWidth = MAX(BEZEL_MIN_WIDTH, textLabelSize.width + BEZEL_LEFT_PADDING + BEZEL_RIGHT_PADDING);
    
    CGRect activityIndicatorFrame = CGRectZero;
    activityIndicatorFrame.size.width = ACTIVITY_INDICATOR_SIZE;
    activityIndicatorFrame.size.height = ACTIVITY_INDICATOR_SIZE;
    activityIndicatorFrame.origin.x = roundf((bezelWidth - activityIndicatorFrame.size.width) * 0.5f);
    activityIndicatorFrame.origin.y = BEZEL_TOP_PADDING;
    self.activityIndicator.frame = activityIndicatorFrame;
    
    CGRect textLabelFrame = CGRectZero;
    textLabelFrame.size = textLabelSize;
    textLabelFrame.origin.x = roundf((bezelWidth - textLabelSize.width) * 0.5f);
    textLabelFrame.origin.y = CGRectGetMaxY(activityIndicatorFrame) + ACTIVITY_INDICATOR_TO_TEXT_LABEL_SPACE;
    self.textLabel.frame = textLabelFrame;
    
    CGRect bezelContainerFrame = CGRectZero;
    bezelContainerFrame.size.width = bezelWidth;
    bezelContainerFrame.size.height = BEZEL_TOP_PADDING + activityIndicatorFrame.size.height + ACTIVITY_INDICATOR_TO_TEXT_LABEL_SPACE + textLabelFrame.size.height + BEZEL_BOTTOM_PADDING;
    bezelContainerFrame.origin.x = roundf((self.bounds.size.width - bezelContainerFrame.size.width) * 0.5f);
    bezelContainerFrame.origin.y = roundf((self.bounds.size.height - bezelContainerFrame.size.height) * 0.5f);
    self.bezelContainerView.frame = bezelContainerFrame;
}

- (void)presentOnTopOfView:(UIView *)parentView
{
    NSASSERT_NOT_NIL(parentView);
    
    self.frame = parentView.bounds;
    [parentView addSubview:self];
    
    [self.activityIndicator startAnimating];
}

- (void)presentAnimatedOnTopOfView:(UIView *)parentView withCompletion:(void (^)())completion
{
    NSASSERT_NOT_NIL(parentView);
    
    self.bezelContainerView.alpha = 0;
    
    self.frame = parentView.bounds;
    [parentView addSubview:self];
    
    [self.activityIndicator startAnimating];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^
    {
        self.bezelContainerView.alpha = 1;
    }
                     completion:^(BOOL finished)
    {
        if (completion)
        {
            completion();
        }
    }];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)dismissAnimatedWithCompletion:(void (^)())completion
{
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^
    {
        self.bezelContainerView.alpha = 0;
    }
                     completion:^(BOOL finished)
    {
        [self removeFromSuperview];
        if (completion)
        {
            completion();
        }
    }];
}

@end
