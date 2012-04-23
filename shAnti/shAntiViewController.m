//
//  shAntiViewController.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiViewController.h"

@interface shAntiViewController ()

@end

@implementation shAntiViewController

@synthesize sv_pageViewSlider   = m_sv_pageViewSlider;
@synthesize pageControl         = m_pageControl;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.sv_pageViewSlider.delegate = self;
        
        [self.sv_pageViewSlider initWithFrame:self.view.frame];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UIPagedScrollView Delegate
- (NSInteger)numberOfPagesInScrollView {
    return 3;
}

- (UIView*)viewForPage:(int)page {
    shAntiUIMeditationView *meditationView = [[[shAntiUIMeditationView alloc] initWithFrame:self.sv_pageViewSlider.frame] autorelease];
    meditationView.delegate = self;
    meditationView.iv_background.image = [UIImage imageNamed:@"stock-photo-2038361-moon-meditation.png"];
    
    return meditationView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the page control
    self.pageControl.currentPage = [self.sv_pageViewSlider currentVisiblePage];
}

#pragma mark - shAntiUIMeditationView Delegate
-(IBAction) onPlayPauseButtonPressed:(id)sender {
    
}

-(IBAction) onVolumeSliderChanged:(id)sender {
    
}


@end
