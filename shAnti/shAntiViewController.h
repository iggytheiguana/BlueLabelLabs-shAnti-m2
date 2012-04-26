//
//  shAntiViewController.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPagedScrollView.h"
#import "shAntiUIMeditationView.h"
#import "shAntiInfoViewController.h"
#import "BaseViewController.h"

@interface shAntiViewController : BaseViewController < UIScrollViewDelegate, UIPagedScrollViewDelegate, shAntiUIMeditationViewDelegate, shAntiInfoViewControllerDelegate > {
    
    UIPagedScrollView   *m_sv_pageViewSlider;
    UIPageControl       *m_pageControl;
    
    NSArray             *m_meditations;
    NSNumber            *m_meditationInstanceID;
}

@property (nonatomic, strong) IBOutlet UIPagedScrollView    *sv_pageViewSlider;
@property (nonatomic, strong) IBOutlet UIPageControl        *pageControl;

@property (nonatomic, strong) NSArray                       *meditations;
@property (nonatomic, strong) NSNumber                      *meditationInstanceID;

@end
