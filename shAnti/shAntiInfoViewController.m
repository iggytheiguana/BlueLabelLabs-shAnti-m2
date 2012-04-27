//
//  shAntiInfoViewController.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/24/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiInfoViewController.h"
#import "shAntiViewController.h"
#import "DateTimeHelper.h"

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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
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
    [self.delegate onContinueButtonPressed:(id)sender];
    
    /*// Prepare meditation scrollview to start from the next mediation
    shAntiViewController *scrollViewController = (shAntiViewController *)self.delegate;
    NSInteger currentPage = [scrollViewController.sv_pageViewSlider currentVisiblePageIndex];
    [scrollViewController.sv_pageViewSlider gotToPageAtIndex:currentPage+1];
    
    [self dismissModalViewControllerAnimated:YES];*/
}

-(IBAction) onScheduleButtonPressed:(id)sender {
    // Create calendar event
    EKEventStore *eventStore = [[[EKEventStore alloc] init] autorelease];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = @"shAnti Meditation Reminder";
    event.location = @"shAnti for iPhone";
    
    // Create the reminder date of the next meditation
    NSDateComponents *time = [[NSCalendar currentCalendar]
                              components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                              fromDate:[NSDate date]];
    
    // Set the reminder start date to 24 hours from now
    NSInteger day = [time day];
    [time setDay:(day + 1)];
    
    NSDate *reminderDateStart = [[NSCalendar currentCalendar] dateFromComponents:time];
    
    // Set the reminder end date to the same day but 1 hour later
    NSInteger hour = [time hour];
    [time setHour:(hour + 1)];
    
    NSDate *reminderDateEnd = [[NSCalendar currentCalendar] dateFromComponents:time];
    
    event.startDate = reminderDateStart;
    event.endDate = reminderDateEnd;
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:(-15 * 60)]];
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    // Launch Event View Controller for editing and saving event
    EKEventEditViewController *eventViewController = [[EKEventEditViewController alloc] init];
    eventViewController.eventStore = eventStore;
    eventViewController.event = event;
    eventViewController.editViewDelegate = self;
    [self presentModalViewController:eventViewController animated:YES];
    [eventViewController release];
}

#pragma mark - EventKitUI delegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissModalViewControllerAnimated:YES];
    
    // Close the Meditation view
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
