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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Set up Paged Scroll View
    [self.sv_pageViewSlider loadView];
    self.sv_pageViewSlider.pagingEnabled = YES;
    self.sv_pageViewSlider.delaysContentTouches = NO;
    
    // Set up PageControl
    [self.pageControl setNumberOfPages:[self numberOfPagesInScrollView]];
    
    [self.sv_pageViewSlider loadVisiblePages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.sv_pageViewSlider = nil;
    self.pageControl = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIPagedScrollView Delegate
- (NSInteger)numberOfPagesInScrollView {
    return 3;
}

- (UIView*)viewForPage:(int)page {
    shAntiUIMeditationView *meditationView = [[[shAntiUIMeditationView alloc] initWithFrame:self.sv_pageViewSlider.frame] autorelease];
    meditationView.delegate = self;
    meditationView.iv_background.image = [UIImage imageNamed:@"stock-photo-2038361-moon-meditation.jpg"];
    NSURL *audioFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                          pathForResource:@"med5"
                                                          ofType:@"mp3"]];
    [meditationView loadAudioWithFile:audioFileURL];
    
    return meditationView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the page control
    self.pageControl.currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    
    // Stop audio
    shAntiUIMeditationView *medittionView = (shAntiUIMeditationView *)[self.sv_pageViewSlider currentVisiblePageView];
    [medittionView stopAudio];
    
}

#pragma mark - shAntiUIMeditationView Delegate
-(IBAction) onDoneButtonPressed:(id)sender {
    shAntiInfoViewController *infoView = [[[shAntiInfoViewController alloc] initWithNibName:@"shAntiInfoViewController" bundle:nil] autorelease];
    infoView.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:infoView];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

-(IBAction) onPlayPauseButtonPressed:(id)sender {
    
}

-(IBAction) onRestartButtonPressed:(id)sender {
    
}


@end
