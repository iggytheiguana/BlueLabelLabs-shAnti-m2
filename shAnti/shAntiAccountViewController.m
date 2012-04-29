//
//  shAntiAccountViewController.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/28/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiAccountViewController.h"
#import <sys/utsname.h>
#import "LoginViewController.h"
#import "shAntiIntroViewController.h"

@interface shAntiAccountViewController ()

@end

@implementation shAntiAccountViewController

@synthesize userID          = m_userID;
@synthesize tc_logout       = m_tc_logout;
@synthesize tc_feedback     = m_tc_feedback;
@synthesize tc_schedule     = m_tc_schedule;
@synthesize tc_introduction = m_tc_introduction;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Set background pattern
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Navigation Bar properties
    self.navigationItem.title = @"Account";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // Navigation Bar Buttons
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(onDoneButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [(UITableView *)self.view reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tc_logout = nil;
    self.tc_feedback = nil;
    self.tc_schedule = nil;
    self.tc_introduction = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions
-(void)scheduleReminder {
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

-(void)sendFeedback {
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
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        // Schedule reminder section
        return @"Add a reminder to meditate to your calendar";
    }
    else {
        return nil;
    }
}*/

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        // Scedule reminder section
        return @"Returning to shanti to practice mindfulness for as little as 2 minutes a day will help you make meditation a habit.";
    }
    else if (section == 1) {
        // Feedback section
        return @"shanti is currently developing more meditations for you to experience. We welcome any feedback to improve shanti for you and others who want to make meditation a habit.";
    }
    else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // Scedule reminder section
        
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"Schedule";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_schedule;
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            return cell;
        }
        
    }
    else if (indexPath.section == 1) {
        // Feedback section
        
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"Feedback";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_feedback;
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        // Introduction replay section
        static NSString *CellIdentifier = @"Introduction";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = self.tc_introduction;
        }
        
        return cell;
    }
    else if (indexPath.section == 3) {
        // Logout section
        static NSString *CellIdentifier = @"Logout";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = self.tc_logout;
        }
        
        if ([self.authenticationManager isUserAuthenticated]) {
            [cell.textLabel setText:@"Logout"];
        }
        else {
            [cell.textLabel setText:@"Login"];
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Scedule reminder section
        
        if (indexPath.row == 0) {
            [self scheduleReminder];
        }
                else {
            //Logout
            if ([self.authenticationManager isUserAuthenticated]) {
                [self.authenticationManager logoff];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    else if (indexPath.section == 1) {
        // Feedback section
        
        if (indexPath.row == 0) {
            [self composeFeedbackMail];
        }
    }
    else if (indexPath.section == 2) {
        // Introduction replay section
        
        if (indexPath.row == 0) {
            shAntiIntroViewController* introViewController = [shAntiIntroViewController createInstance];
            
            UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:introViewController];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
            
            [self presentModalViewController:navigationController animated:YES];
            [navigationController release];

        }
    }
    else if (indexPath.section == 3) {
        // Logout section
        
        if (indexPath.row == 0) {
            if ([self.authenticationManager isUserAuthenticated]) {
                [self.authenticationManager logoff];
                [self dismissModalViewControllerAnimated:YES];
            }
            else {
                LoginViewController* loginViewController = [LoginViewController createAuthenticationInstance:YES shouldGetTwitter:NO onSuccessCallback:nil onFailureCallback:nil];
                
                UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
                navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                
                [self presentModalViewController:navigationController animated:YES];
                [navigationController release];
            }
        }
    }
}

#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Static Initializer
+ (shAntiAccountViewController*)createInstance {
    shAntiAccountViewController* accountViewController = [[shAntiAccountViewController alloc]initWithNibName:@"shAntiAccountViewController" bundle:nil];
    [accountViewController autorelease];
    
    return accountViewController;
}

@end
