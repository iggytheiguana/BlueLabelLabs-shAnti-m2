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

#define PADDING 20

@interface shAntiViewController ()

@end

@implementation shAntiViewController

@synthesize sv_pageViewSlider   = m_sv_pageViewSlider;
@synthesize pageControl         = m_pageControl;
@synthesize meditations         = m_meditations;
@synthesize meditationInstanceID = m_meditationInstanceID;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
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
    
    // Load default data on first run
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:setting_ISFIRSTRUN] == nil || [userDefaults boolForKey:setting_ISFIRSTRUN] == YES) {
        // This is the first run of the app, set up default meditation objects
        self.meditations = [Meditation loadDefaultMeditations];
        
        // Save the Meditation objects
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
        
        // Create user default settings for first run, sequence completion, and last position
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:setting_ISFIRSTRUN];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:setting_HASCOMPLETEDSEQUENCE];
        [userDefaults setObject:[NSNumber numberWithInt:0] forKey:setting_LASTPOSITION];
        [userDefaults synchronize];
    }
    else {
        //we load them the meditations from the ResourceContext
        ResourceContext* resourceContext = [ResourceContext instance];
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
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self.authenticationManager isUserAuthenticated]) 
    {
        Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNotificationsButtonClicked:) withContext:nil];        
        Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];
        
        
        [onSucccessCallback release];
        [onFailCallback release];
    }
    
    
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
    int count = [self.meditations count];
    return count;
}

- (UIView*)viewForPage:(int)page {
    shAntiUIMeditationView *meditationView = [[[shAntiUIMeditationView alloc] initWithFrame:self.sv_pageViewSlider.frame] autorelease];
    meditationView.delegate = self;
    
    // Get the Meditation object for the page
    Meditation *meditation = [self.meditations objectAtIndex:page];
    
    meditationView.lbl_titleLabel.text = meditation.title;
    
    meditationView.iv_background.image = [UIImage imageNamed:meditation.imageurl];
    //meditationView.iv_background.image = [UIImage imageNamed:@"stock-photo-2038361-moon-meditation.jpg"];
    
    NSURL *audioFileURL = [NSURL URLWithString:meditation.audiourl];
    //NSURL *audioFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
    //                                                      pathForResource:@"med5short"
    //                                                      ofType:@"mp3"]];
    [meditationView loadAudioWithFile:audioFileURL];
    
    return meditationView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Stop audio
    shAntiUIMeditationView *meditationView = (shAntiUIMeditationView *)[self.sv_pageViewSlider currentVisiblePageView];
    [meditationView stopAudio];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the page control
    self.pageControl.currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
}

#pragma mark - shAntiUIMeditationView Delegate
-(IBAction)onDoneButtonPressed:(id)sender {
    //shAntiInfoViewController *infoView = [[[shAntiInfoViewController alloc] initWithNibName:@"shAntiInfoViewController" bundle:nil] autorelease];
    shAntiInfoViewController *infoView = [shAntiInfoViewController createInstanceWithMessage:ui_INFO_SCHEDULEREMINDER4 showFeedbackButton:NO];
    infoView.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:infoView];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

-(IBAction)onInfoButtonPressed:(id)sender {
    shAntiInfoViewController *infoView = [shAntiInfoViewController createInstanceWithMessage:ui_INFO_SCHEDULEREMINDER4 showFeedbackButton:YES];
    infoView.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:infoView];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

-(IBAction)onPlayPauseButtonPressed:(id)sender {
    
}

-(IBAction)onRestartButtonPressed:(id)sender {
    
}

-(void)meditationDidStart {
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
    ResourceContext* resourceContext = [ResourceContext instance];
        
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
    // Get the Meditation object for the page
    NSInteger currentPage = [self.sv_pageViewSlider currentVisiblePageIndex];
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
        
        //[resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
    }
    else {
        // Meditation was stopped before full duration was completed
        // Update properties of meditation instance
        meditationInstance.state = state;

    }
    
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
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
