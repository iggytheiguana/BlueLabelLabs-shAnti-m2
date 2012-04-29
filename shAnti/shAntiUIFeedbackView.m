//
//  shAntiUIFeedbackView.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/28/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiUIFeedbackView.h"

@implementation shAntiUIFeedbackView

@synthesize btn_feedback    = m_btn_feedback;
@synthesize view            = m_view;


#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<shAntiUIFeedbackViewDelegate>)del
{
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"shAntiUIFeedbackView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load shAntiUIFeedbackView file.\n");
        }
        
        // Set background pattern
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        
        // Setup buttons
        UIImage *feedbackButtonImageNormal = [UIImage imageNamed:@"button_roundrect_blue.png"];
        UIImage *stretchableFeedbackButtonImageNormal = [feedbackButtonImageNormal stretchableImageWithLeftCapWidth:44 topCapHeight:22];
        [self.btn_feedback setBackgroundImage:stretchableFeedbackButtonImageNormal forState:UIControlStateNormal];
        [self.btn_feedback.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
        
        [self addSubview:self.view];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIButton Handlers
-(IBAction)onFeedbackButtonPressed:(id)sender {
    [self.delegate onFeedbackButtonPressed:sender];
}

@end
