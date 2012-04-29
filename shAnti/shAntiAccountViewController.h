//
//  shAntiAccountViewController.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/28/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EKEventEditViewController.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"

@interface shAntiAccountViewController : BaseViewController < UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, EKEventEditViewDelegate, MFMailComposeViewControllerDelegate > {
    
    NSNumber*           m_userID;
    
    UITableViewCell*    m_tc_introduction;
    UITableViewCell*    m_tc_feedback;
    UITableViewCell*    m_tc_schedule;
    UITableViewCell*    m_tc_logout;
    
}

@property (atomic, retain) NSNumber     *userID;

@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_introduction;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_feedback;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_schedule;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_logout;

+ (shAntiAccountViewController*)createInstance;

@end
