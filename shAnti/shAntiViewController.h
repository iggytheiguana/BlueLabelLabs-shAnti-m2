//
//  shAntiViewController.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UIPagedScrollView.h"
#import "shAntiUIMeditationView.h"
#import "shAntiInfoViewController.h"
#import "shAntiUIFeedbackView.h"
#import "BaseViewController.h"
#include <AudioToolbox/AudioToolbox.h>

@interface shAntiViewController : BaseViewController < UIScrollViewDelegate, UIPagedScrollViewDelegate, shAntiUIMeditationViewDelegate, shAntiInfoViewControllerDelegate, MFMailComposeViewControllerDelegate, shAntiUIFeedbackViewDelegate > {
    
    UIPagedScrollView   *m_sv_pageViewSlider;
    UIPageControl       *m_pageControl;
    UIButton            *m_btn_pageLeft;
    UIButton            *m_btn_pageRight;
    
    NSArray             *m_meditations;
    NSNumber            *m_meditationInstanceID;
    
    SystemSoundID       bellSound;
}

@property (nonatomic, strong) IBOutlet UIPagedScrollView    *sv_pageViewSlider;
@property (nonatomic, strong) IBOutlet UIPageControl        *pageControl;
@property (nonatomic, strong) IBOutlet UIButton             *btn_pageLeft;
@property (nonatomic, strong) IBOutlet UIButton             *btn_pageRight;

@property (nonatomic, strong) NSArray                       *meditations;
@property (nonatomic, strong) NSNumber                      *meditationInstanceID;

-(IBAction)onPageLeftButtonPressed:(id)sender;
-(IBAction)onPageRightButtonPressed:(id)sender;

@end
