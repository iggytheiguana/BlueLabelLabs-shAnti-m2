//
//  shAntiInfoViewController.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/24/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventKitUI/EKEventEditViewController.h"
#import <MessageUI/MessageUI.h>

@protocol shAntiInfoViewControllerDelegate <NSObject>

-(IBAction) onContinueButtonPressed:(id)sender;

@end

@interface shAntiInfoViewController : UIViewController < EKEventEditViewDelegate, MFMailComposeViewControllerDelegate > {
    id<shAntiInfoViewControllerDelegate> m_delegate;
    
    NSString    *m_message;
    UILabel     *m_lbl_message;
    
    BOOL        m_showFeedbackButton;
    UIButton    *m_btn_feedback;
    UIButton    *m_btn_schedule;
}

@property (nonatomic, assign) id<shAntiInfoViewControllerDelegate> delegate;

@property (nonatomic, retain) NSString              *message;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_message;

@property                     BOOL                  showFeedbackButton;
@property (nonatomic, retain) IBOutlet UIButton     *btn_feedback;
@property (nonatomic, retain) IBOutlet UIButton     *btn_schedule;

-(IBAction) onScheduleButtonPressed:(id)sender;

+ (shAntiInfoViewController*)createInstanceWithMessage:(NSString *)message showFeedbackButton:(BOOL)feedback;

@end
