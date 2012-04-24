//
//  shAntiInfoViewController.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/24/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiInfoViewController.h"
#import "shAntiViewController.h"

@interface shAntiInfoViewController ()

@end

@implementation shAntiInfoViewController

@synthesize btn_continue    = m_btn_continue;
@synthesize btn_schedule    = m_btn_schedule;
@synthesize lbl_message     = m_lbl_message;


#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<shAntiInfoViewControllerDelegate>)del
{
    m_delegate = del;
}

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
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES animated:NO]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.btn_continue = nil;
    self.btn_schedule = nil;
    self.lbl_message = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Event Handlers
-(IBAction) onContinueButtonPressed:(id)sender {
    // Prepare meditation scrollview to start from the next mediation
    shAntiViewController *scrollViewController = (shAntiViewController *)self.delegate;
    NSInteger currentPage = [scrollViewController.sv_pageViewSlider currentVisiblePageIndex];
    [scrollViewController.sv_pageViewSlider gotToPageAtIndex:currentPage+1];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction) onScheduleButtonPressed:(id)sender {
    
}

@end
