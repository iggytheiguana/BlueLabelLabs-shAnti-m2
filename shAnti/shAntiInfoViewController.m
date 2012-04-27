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
#import <sys/utsname.h>

@interface shAntiInfoViewController ()

@end

@implementation shAntiInfoViewController

@synthesize message         = m_message;
@synthesize lbl_message     = m_lbl_message;
@synthesize showFeedbackButton = m_showFeedbackButton;
@synthesize btn_feedback    = m_btn_feedback;
@synthesize btn_schedule    = m_btn_schedule;


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
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Navigation Bar properties
    self.navigationItem.title = @"shAnti";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // Navigation Bar Buttons
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(onContinueButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Set background pattern
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
    
    // Setup buttons
    UIImage *feedbackButtonImageNormal = [UIImage imageNamed:@"button_roundrect_lightgrey.png"];
    UIImage *stretchableFeedbackButtonImageNormal = [feedbackButtonImageNormal stretchableImageWithLeftCapWidth:44 topCapHeight:22];
    [self.btn_feedback setBackgroundImage:stretchableFeedbackButtonImageNormal forState:UIControlStateNormal];
    [self.btn_feedback.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    
    /*UIImage *feedbackButtonImageSelected = [UIImage imageNamed:@"button_roundrect_lightgrey_selected.png"];
    UIImage *stretchableFeedbackButtonImageSelected = [feedbackButtonImageSelected stretchableImageWithLeftCapWidth:44 topCapHeight:22];
    [self.btn_feedback setBackgroundImage:stretchableFeedbackButtonImageSelected forState:UIControlStateSelected];*/
    
    UIImage *scheduleButtonImageNormal = [UIImage imageNamed:@"button_roundrect_blue.png"];
    UIImage *stretchableScheduleButtonImageNormal = [scheduleButtonImageNormal stretchableImageWithLeftCapWidth:44 topCapHeight:22];
    [self.btn_schedule setBackgroundImage:stretchableScheduleButtonImageNormal forState:UIControlStateNormal];
    [self.btn_schedule.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    
    /*UIImage *scheduleButtonImageSelected = [UIImage imageNamed:@"button_roundrect_lightgrey_selected.png"];
    UIImage *stretchableScheduleButtonImageSelected = [scheduleButtonImageSelected stretchableImageWithLeftCapWidth:44 topCapHeight:22];
    [self.btn_feedback setBackgroundImage:stretchableScheduleButtonImageSelected forState:UIControlStateSelected];*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.btn_feedback = nil;
    self.btn_schedule = nil;
    self.lbl_message = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lbl_message.text = self.message;
    [self.btn_feedback setHidden:!self.showFeedbackButton];
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

-(IBAction)onFeedbackButtonPressed:(id)sender {
    [self composeFeedbackMail];
}

#pragma mark - Feedback Mail Helper	
NSString*	
machineNameSettings()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (void)composeFeedbackMail {
    // Get version information about the app and phone to prepopulate in the email
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionNum = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString* deviceType = machineNameSettings();
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the email subject
    [picker setSubject:[NSString stringWithFormat:@"%@ Feedback!", appName]];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"contact@bluelabellabs.com", nil];
    [picker setToRecipients:toRecipients];
    
    NSString *messageHeader = [NSString stringWithFormat:@"I'm using %@ version %@ on my %@ running iOS %@, %@.<br><br>--- Please add your message below this line ---", appName, appVersionNum, deviceType, currSysVer, [loggedInUserID stringValue]];
    [picker setMessageBody:messageHeader isHTML:YES];
    
    // Present the mail composition interface
    [self presentModalViewController:picker animated:YES];
    [picker release]; // Can safely release the controller now.
}

#pragma mark - MailComposeController Delegate
// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - EventKitUI delegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissModalViewControllerAnimated:YES];
    
    // Close the Meditation view
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Static Initializers
+ (shAntiInfoViewController*)createInstanceWithMessage:(NSString *)message showFeedbackButton:(BOOL)feedback {
    //returns an instance of the shAntiInfoViewController configured 
    shAntiInfoViewController* instance = [[[shAntiInfoViewController alloc]initWithNibName:@"shAntiInfoViewController" bundle:nil]autorelease];

    instance.message = message;
    instance.showFeedbackButton = feedback;
    return instance;
}

@end
