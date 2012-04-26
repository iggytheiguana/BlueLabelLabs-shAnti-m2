//
//  shAntiInfoViewController.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/24/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventKitUI/EKEventEditViewController.h"

@protocol shAntiInfoViewControllerDelegate <NSObject>

-(IBAction) onContinueButtonPressed:(id)sender;

@end

@interface shAntiInfoViewController : UIViewController < EKEventEditViewDelegate > {
    id<shAntiInfoViewControllerDelegate> m_delegate;
    
    UILabel     *m_lbl_message;
    
    UIButton    *m_btn_continue;
    UIButton    *m_btn_schedule;
}

@property (nonatomic, assign) id<shAntiInfoViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UILabel      *lbl_message;

@property (nonatomic, retain) IBOutlet UIButton     *btn_continue;
@property (nonatomic, retain) IBOutlet UIButton     *btn_schedule;

//-(IBAction) onContinueButtonPressed:(id)sender;
-(IBAction) onScheduleButtonPressed:(id)sender;

@end
