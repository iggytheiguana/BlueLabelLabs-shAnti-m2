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

@interface shAntiViewController : UIViewController < UIScrollViewDelegate, UIPagedScrollViewDelegate, shAntiUIMeditationViewDelegate, shAntiInfoViewControllerDelegate > {
    
    UIPagedScrollView   *m_sv_pageViewSlider;
    UIPageControl       *m_pageControl;
    
    NSArray             *m_meditations;
}

@property (nonatomic, strong) IBOutlet UIPagedScrollView    *sv_pageViewSlider;
@property (nonatomic, strong) IBOutlet UIPageControl        *pageControl;

@property (nonatomic, strong) NSArray                       *meditations;

@end
