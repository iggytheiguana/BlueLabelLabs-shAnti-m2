//
//  shAntiViewController.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiViewController.h"
#import "UserDefaultSettings.h"
#import "Meditation.h"
#import "MeditationInstance.h"
#import "MeditationState.h"
#import "NSMutableArray+NSMutableArrayCategory.h"
#import "UIStrings.h"
#import "shAntiAccountViewController.h"
#import "shAntiUIFeedbackView.h"
#import <sys/utsname.h>
#import "shAntiIntroViewController.h"

#define PADDING 20

@interface shAntiViewController ()

@end

@implementation shAntiViewController

@synthesize sv_pageViewSlider   = m_sv_pageViewSlider;
@synthesize pageControl         = m_pageControl;
@synthesize btn_pageLeft        = m_btn_pageLeft;
@synthesize btn_pageRight       = m_btn_pageRight;
@synthesize meditations         = m_meditations;
@synthesize meditationInstanceID = m_meditationInstanceID;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Set background pattern
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        
        // Add shadow to the page control indicator
        self.pageControl.layer.shadowColor = [UIColor blackColor].CGColor;
        self.pageControl.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.pageControl.layer.shadowOpacity = 1.0;   
        self.pageControl.layer.shadowRadius = 5.0;
        
    }
    return self;
}

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ResourceContext *resourceContext = [ResourceContext instance];
    
    // Load default data on first run
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Create user default settings for holding the app version
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionCurrent = [infoDict objectForKey:@"CFBundleVersion"];
    //NSString* appVersionCurrent = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    if ([userDefaults objectForKey:setting_APPVERSION] == nil) {
        // This is the first run of the app, save the current app version
        [userDefaults setObject:appVersionCurrent forKey:setting_APPVERSION];
        
        // Make user defaults as first run
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:setting_ISFIRSTRUN];
        
        // Delete all the previous meditation objects
        NSArray *meditations = [resourceContext resourcesWithType:MEDITATION];
        Meditation *meditation = [Meditation alloc];
        
        for (int i = 0; i < meditations.count; i++) {
            meditation = [meditations objectAtIndex:i];
            
            [resourceContext delete:meditation.objectid withType:MEDITATION];
        }
    }
    else {
        NSString* appVersionUser = [userDefaults objectForKey:setting_APPVERSION];
        //NSString* appVersionUser = [userDefaults objectForKey:setting_APPVERSION];
        
        if (![appVersionCurrent isEqualToString:appVersionUser]) {
            // Users local data is from a different app version we need to reset to furst run experience
            [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:setting_ISFIRSTRUN];
            
            // Delete all the previous meditation objects
            NSArray *meditations = [resourceContext resourcesWithType:MEDITATION];
            Meditation *meditation = [Meditation alloc];
            
            for (int i = 0; i < meditations.count; i++) {
                meditation = [meditations objectAtIndex:i];
                
                [resourceContext delete:meditation.objectid withType:MEDITATION];
            }
        }
    }
    [userDefaults synchronize];
    
    
    // Check if first run
    if ([userDefaults objectForKey:setting_ISFIRSTRUN] == nil || [userDefaults boolForKey:setting_ISFIRSTRUN] == YES) {
        // This is the first run of the app, set up default meditation objects
        self.meditations = [Meditation loadDefaultMeditations];
        
        // Save the Meditation objects
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
        
        // Create user default settings for sequence completion, last position, and logged in check
        //[userDefaults setObject:[NSNumber numberWithBool:NO] forKey:setting_ISFIRSTRUN];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:setting_HASCOMPLETEDSEQUENCE];
        [userDefaults setObject:[NSNumber numberWithInt:0] forKey:setting_LASTPOSITION];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:setting_DIDSKIPLOGIN];
        [userDefaults synchronize];
    }
    else {
        //we load them the meditations from the ResourceContext
        self.meditations = [resourceContext resourcesWithType:MEDITATION];
        
        // Check to see if all meditation objects in the array have been completed at least once
        Meditation *meditation = [Meditation alloc];
        for (int i = 0; i < self.meditations.count; i++) {
            meditation = [self.meditations objectAtIndex:i];
            
            if ([meditation.numtimescompleted intValue] == 0) {
                // If just one of the meditations has not been completed yet,
                // we reset hascompletedsequence to FALSE and
                // set the last position to this incompleted meditation
                [userDefaults setBool:NO forKey:setting_HASCOMPLETEDSEQUENCE];
                [userDefaults setInteger:i forKey:setting_LASTPOSITION];
                
                if ([self.authenticationManager isUserAuthenticated]) {
                    self.loggedInUser.lastposition = [NSNumber numberWithInt:i];
                }
                break;
            }
            else {
                [userDefaults setBool:YES forKey:setting_HASCOMPLETEDSEQUENCE];
            }
        }
        
        // Set login check back to default
        [userDefaults setBool:NO forKey:setting_DIDSKIPLOGIN];
        
        [userDefaults synchronize];
    }
    
    // Shuffle the meditations array if the user has already completed the sequence
    if ([userDefaults boolForKey:setting_HASCOMPLETEDSEQUENCE] == YES) {
        // Shuffle the meditations array
        NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:self.meditations];
        [shuffledArray shuffle];
        
        self.meditations = shuffledArray;
    }
    
    // Setup Paged Scroll View
	self.sv_pageViewSlider.frame = [self frameForPagingScrollView];
    [self.sv_pageViewSlider loadView];
    self.sv_pageViewSlider.padding = PADDING;
    self.sv_pageViewSlider.pagingEnabled = YES;
    self.sv_pageViewSlider.delaysContentTouches = NO;
    self.sv_pageViewSlider.showsHorizontalScrollIndicator = NO;
    self.sv_pageViewSlider.showsVerticalScrollIndicator = NO;
    //[self.sv_pageViewSlider setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
    
    // Set up PageControl
    [self.pageControl setNumberOfPages:[self numberOfPagesInScrollView]];
    
    // Move Paged Scroll View to the appropriate page
    if ([userDefaults objectForKey:setting_HASCOMPLETEDSEQUENCE] != nil && 
        [userDefaults boolForKey:setting_HASCOMPLETEDSEQUENCE] == NO) {
        
        // User has not fully completed sequence yet, load first incomplete meditation in sequence
        [self.sv_pageViewSlider loadVisiblePages];
        [self.sv_pageViewSlider goToPageAtIndex:[userDefaults integerForKey:setting_LASTPOSITION] animated:NO];
    }
    else {
        // User has fully completed sequence, load first page of shuffled meditations array
        [self.sv_pageViewSlider loadVisiblePages];
    }
    
    // Load the bell sound used at the end of mediations
    CFURLRef bellURL = (CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                      pathForResource:@"LittleBell"
                                                      ofType:@"mp3"]];
    
    AudioServicesCreateSystemSoundID(bellURL, &bellSound);
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![self.authenticationManager isUserAuthenticated] && [userDefaults boolForKey:setting_DIDSKIPLOGIN] == NO) {
        Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNotificationsButtonClicked:) withContext:nil];        
        Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];
        
        [onSucccessCallback release];
        [onFailCallback release];
    }
    else if ([userDefaults objectForKey:setting_ISFIRSTRUN] == nil || [userDefaults boolForKey:setting_ISFIRSTRUN] == YES) {
        // Create user default settings for first run
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:setting_ISFIRSTRUN];
        [userDefaults synchronize];
        
        // Launch introduction view controller
        shAntiIntroViewController* introViewController = [shAntiIntroViewController createInstance];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:introViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        
        [self presentModalViewController:navigationController animated:YES];
        [navigationController release];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Check to see if we are on the last page or first page to hide unneeded chevrons
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    NSInteger numPages = [self numberOfPagesInScrollView];
    
    if (currentPage == 0) {
        [self.btn_pageLeft setHidden:YES];
    }
    else if (currentPage == (numPages-1)) {
        [self.btn_pageRight setHidden:YES];
    }
    else {
        [self.btn_pageLeft setHidden:NO];
        [self.btn_pageRight setHidden:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.sv_pageViewSlider = nil;
    self.pageControl = nil;
    self.btn_pageLeft = nil;
    self.btn_pageRight = nil;
}

- (void) dealloc {
    AudioServicesDisposeSystemSoundID(bellSound);
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Button Handlers
-(IBAction)onPageLeftButtonPressed:(id)sender {
    // Move scrollview to the previous page
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    
    if (currentPage > 0) {
        [self.sv_pageViewSlider goToPageAtIndex:currentPage-1 animated:YES];
    }
}

-(IBAction)onPageRightButtonPressed:(id)sender {
    // Move scrollview to the next page
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    NSInteger numPages = [self numberOfPagesInScrollView];
    
    if (currentPage < numPages) {
        [self.sv_pageViewSlider goToPageAtIndex:currentPage+1 animated:YES];
    }
}

#pragma mark - Bell Sound Player
- (void) playBell {
    AudioServicesPlaySystemSound(bellSound);
}

#pragma mark - Feedback Mail Helper	
NSString*	
machineNameSettingsFeedback()
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
    NSString* deviceType = machineNameSettingsFeedback();
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the email subject
    [picker setSubject:[NSString stringWithFormat:@"%@ Feedback!", appName]];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"aarora1@stanford.edu", nil];
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

#pragma mark - UIPagedScrollView Delegate
- (NSInteger)numberOfPagesInScrollView {
    int count = [self.meditations count];
    return count + 1;   // We add one to the count of meditation objects to account for the feedback page at the end
}

- (UIView*)viewForPage:(int)page {
    UIView *pageView;
    
    int meditationsCount = [self.meditations count];
    
    if (page == meditationsCount) {
        // Return the feedback page
        shAntiUIFeedbackView *feedbackView = [[[shAntiUIFeedbackView alloc] initWithFrame:self.sv_pageViewSlider.frame] autorelease];
        feedbackView.delegate = self;
        
        pageView = (UIView *)feedbackView;
    }
    else {
        shAntiUIMeditationView *meditationView = [[[shAntiUIMeditationView alloc] initWithFrame:self.sv_pageViewSlider.frame] autorelease];
        meditationView.delegate = self;
        
        // Get the Meditation object for the page
        Meditation *meditation = [self.meditations objectAtIndex:page];
        
        meditationView.lbl_titleLabel.text = meditation.title;
        
        meditationView.iv_background.image = [UIImage imageNamed:meditation.imageurl];
        
        NSURL *audioFileURL = [NSURL URLWithString:meditation.audiourl];
        
        [meditationView loadAudioWithFile:audioFileURL];
        
        pageView = (UIView *)meditationView;
    }
    
    return pageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Stop audio
    
    if (self.sv_pageViewSlider.currentVisiblePageIndex != [self.meditations count]) {
        // only process if we are not at the last page
        shAntiUIMeditationView *meditationView = (shAntiUIMeditationView *)[self.sv_pageViewSlider currentVisiblePageView];
        [meditationView stopAudio];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the page control
    self.pageControl.currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    
    // Check to see if we are on the last page or first page to hide unneeded chevrons
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    NSInteger numPages = [self numberOfPagesInScrollView];
    
    if (currentPage == 0) {
        [self.btn_pageLeft setHidden:YES];
    }
    else if (currentPage == (numPages-1)) {
        [self.btn_pageRight setHidden:YES];
    }
    else {
        [self.btn_pageLeft setHidden:NO];
        [self.btn_pageRight setHidden:NO];
    }
}

#pragma mark - shAntiUIMeditationView Delegate
-(IBAction)onDoneButtonPressed:(id)sender {
    shAntiInfoViewController *infoView = [shAntiInfoViewController createInstanceWithMessage:ui_INFO_SCHEDULEREMINDER1 showFeedbackButton:NO];
    infoView.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:infoView];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

-(IBAction)onInfoButtonPressed:(id)sender {
    shAntiAccountViewController *accountViewController = [shAntiAccountViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:accountViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

-(IBAction)onPlayPauseButtonPressed:(id)sender {
    UIButton *playPauseButton = (UIButton *)sender;
    
    if (playPauseButton.selected) {
        // Playing
        // Lock the slider
        [self.sv_pageViewSlider setScrollEnabled:NO];
        
        // Hide the page indicator
        [self.pageControl setHidden:YES];
        
        // Hide the scroll buttons
        [self.btn_pageLeft setHidden:YES];
        [self.btn_pageRight setHidden:YES];
    }
    else {
        // Paused
        // Unlock the slider
        [self.sv_pageViewSlider setScrollEnabled:YES];
        
        // Show the page indicator
        [self.pageControl setHidden:NO];

        // Show the scroll buttons
        NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
        NSInteger numPages = [self numberOfPagesInScrollView];
        
        if (currentPage == 0) {
            [self.btn_pageLeft setHidden:YES];
            [self.btn_pageRight setHidden:NO];
        }
        else if (currentPage == (numPages-1)) {
            [self.btn_pageLeft setHidden:NO];
            [self.btn_pageRight setHidden:YES];
        }
        else {
            [self.btn_pageLeft setHidden:NO];
            [self.btn_pageRight setHidden:NO];
        }
    }
}

-(IBAction)onRestartButtonPressed:(id)sender {
    
}

-(void)meditationDidStart {
    // Lock the slider
    [self.sv_pageViewSlider setScrollEnabled:NO];
    
    // Hide the page indicator
    [self.pageControl setHidden:YES];
    
    // Hide the scroll buttons
    [self.btn_pageLeft setHidden:YES];
    [self.btn_pageRight setHidden:YES];
    
    // Get the Meditation object for the page
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    Meditation *meditation = [self.meditations objectAtIndex:currentPage];
    
    NSNumber* loggedInUserID;
    if ([self.authenticationManager isUserAuthenticated]) {
        loggedInUserID = [[AuthenticationManager instance]m_LoggedInUserID];
    }
    else {
        loggedInUserID = nil;
    }
    
    // Create a new meditation instance
    MeditationInstance* meditationInstance = [MeditationInstance createInstanceOfMeditation:meditation.objectid forUserID:loggedInUserID withState:[NSNumber numberWithInt:kINPROGRESS] withScheduledDate:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    
    // Save new meditation instance
    ResourceContext *resourceContext = [ResourceContext instance];
        
    // Increment the counter for the number of times this meditation has been started
    NSInteger numTimesStarted = [meditation.numtimesstarted intValue] + 1;
    meditation.numtimesstarted = [NSNumber numberWithInt:numTimesStarted];
    
    // Mark the last position of the user to this meditation
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:[meditation.position intValue] forKey:setting_LASTPOSITION];
    
    if ([self.authenticationManager isUserAuthenticated]) {
        self.loggedInUser.lastposition = meditation.position;
    }
    
    // Store the new meditation instance locally
    self.meditationInstanceID = meditationInstance.objectid;
    
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
}

- (void)meditationDidFinishWithState:(NSNumber *)state {
    // Unlock the slider
    [self.sv_pageViewSlider setScrollEnabled:YES];
    
    // Show the page indicator
    [self.pageControl setHidden:NO];
    
    // Show the scroll buttons
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    NSInteger numPages = [self numberOfPagesInScrollView];
    
    if (currentPage == 0) {
        [self.btn_pageLeft setHidden:YES];
        [self.btn_pageRight setHidden:NO];
    }
    else if (currentPage == (numPages-1)) {
        [self.btn_pageLeft setHidden:NO];
        [self.btn_pageRight setHidden:YES];
    }
    else {
        [self.btn_pageLeft setHidden:NO];
        [self.btn_pageRight setHidden:NO];
    }
    
    // Get the Meditation object for the page
    Meditation *meditation = [self.meditations objectAtIndex:currentPage];
    
    // Get the associated MeditationInstance
    ResourceContext *resourceContext = [ResourceContext instance];
    MeditationInstance *meditationInstance = (MeditationInstance *)[resourceContext resourceWithType:MEDITATIONINSTANCE withID:self.meditationInstanceID];
    
    if ([state intValue] == kMEDITATIONCOMPLETED) {
        // Meditation finsished its full specified duration
        
        // Increment the counter for the number of times this meditation has been completed
        NSInteger numTimesCompleted = [meditation.numtimescompleted intValue] + 1;
        meditation.numtimescompleted = [NSNumber numberWithInt:numTimesCompleted];
        
        // Update properties of meditation instance
        meditationInstance.state = state;
        meditationInstance.datecompleted = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
        
        // Play bell sound
        [self playBell];
    }
    else {
        // Meditation was stopped before full duration was completed
        // Update properties of meditation instance
        meditationInstance.state = state;
        
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
    }
    
}

#pragma mark - shAntiUIFeedbackViewController Delegate
-(IBAction)onFeedbackButtonPressed:(id)sender {
    [self composeFeedbackMail];
}

#pragma mark - shAntiInfoViewController Delegate
-(IBAction)onContinueButtonPressed:(id)sender {
    // Dismiss the modal info view
    [self dismissModalViewControllerAnimated:YES];
    
    // Move scrollview to start from the next mediation
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
    
    /*NSNumber *nextPage = [NSNumber numberWithInt:(currentPage+1)];
    NSNumber *animated = [NSNumber numberWithBool:YES];
    
    NSArray *selectorObjects = [NSArray arrayWithObjects: nextPage, animated, nil];
    
    [self.sv_pageViewSlider performSelector:@selector(goToPageAtIndexWithObjects:) withObject:selectorObjects afterDelay:1.5];*/
    
    [self.sv_pageViewSlider goToPageAtIndex:currentPage+1 animated:NO];
}


@end
