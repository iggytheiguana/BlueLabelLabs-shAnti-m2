//
//  shAntiUIFeedbackView.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/28/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol shAntiUIFeedbackViewDelegate <NSObject>
@required

-(IBAction)onFeedbackButtonPressed:(id)sender;

@end

@interface shAntiUIFeedbackView : UIView {
    id<shAntiUIFeedbackViewDelegate> m_delegate;
    
    UIView  *m_view;
    
    UIButton    *m_btn_feedback;
}

@property (nonatomic, assign) id<shAntiUIFeedbackViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView       *view;
@property (nonatomic, retain) IBOutlet UIButton     *btn_feedback;

-(IBAction)onFeedbackButtonPressed:(id)sender;

@end
