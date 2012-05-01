//
//  shAntiIntroViewController.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/29/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiIntroViewController.h"
#import "MeditationState.h"
#import <QuartzCore/QuartzCore.h>

@interface shAntiIntroViewController ()

@end

@implementation shAntiIntroViewController

@synthesize lbl_titleLabel      = m_lbl_titleLabel;
@synthesize lbl_instructionLabel = m_lbl_instructionLabel;
@synthesize btn_playPause       = m_btn_playPause;
@synthesize btn_restart         = m_btn_restart;
@synthesize sld_volumeControl   = m_sld_volumeControl;
@synthesize audioPlayer         = m_audioPlayer;


-(void)loadAudioWithFile:(NSURL*)url {
    // Add audio file to player
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        self.audioPlayer.delegate = self;
        
        // Get player ready for playing
        [self.audioPlayer setCurrentTime:0];
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.volume = 0.5;
        self.sld_volumeControl.value = 0.5;
        [self.audioPlayer prepareToPlay];
    }
    
    // Set the audio player to keep playing when the screen locks
    // Implicitly initializes audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // Activate the audio session
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (activationError) {
        NSLog(@"ERROR ACTIVATION AUDIO SESSION!\n");
    }
    
    // Set the audio session category
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (setCategoryError) {
        NSLog(@"ERROR SETTING AUDIO CATEGORY!\n");
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Set background pattern
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern.png"]]];
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        
        CGFloat scale = [[UIScreen mainScreen] scale]; 
        
        // Add shadow to title label
        self.lbl_titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.lbl_titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.lbl_titleLabel.layer.shadowOpacity = 1;   
        self.lbl_titleLabel.layer.shadowRadius = 2.0;
        self.lbl_titleLabel.layer.shouldRasterize = YES;
        self.lbl_titleLabel.layer.rasterizationScale = scale;
        self.lbl_titleLabel.clipsToBounds = NO;
        
        // Add shadow to instruction label
        self.lbl_instructionLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.lbl_instructionLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.lbl_instructionLabel.layer.shadowOpacity = 1;   
        self.lbl_instructionLabel.layer.shadowRadius = 2.0;
        self.lbl_instructionLabel.layer.shouldRasterize = YES;
        self.lbl_instructionLabel.layer.rasterizationScale = scale;
        self.lbl_instructionLabel.clipsToBounds = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Bar properties
    self.navigationItem.title = @"Welcome";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // Navigation Bar Buttons
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(onDoneButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    NSString *audioURL = [[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"MindfulnessIntro"
                                                  ofType:@"mp3"]] absoluteString];
    NSURL *audioFileURL = [NSURL URLWithString:audioURL];
    [self loadAudioWithFile:audioFileURL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.lbl_titleLabel = nil;
    self.lbl_instructionLabel = nil;
    self.btn_playPause = nil;
    self.btn_restart = nil;
    self.sld_volumeControl = nil;
    self.audioPlayer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Audio Action Methods
-(void)playAudio
{    
    [self.audioPlayer play];
    
    // Reset Pause button
    [self.btn_playPause setSelected:YES];
}

-(void)pauseAudio
{
    [self.audioPlayer pause];
    
    // Reset Play button
    [self.btn_playPause setSelected:NO];
}

-(void)rewindAudio
{
    [self.audioPlayer setCurrentTime:0.0];
}

-(void)stopAudio
{
    [self.audioPlayer stop];
    
    // Reset Play button
    [self.btn_playPause setSelected:NO];
    
    // Set the appropriate state for the meditation instance
    //if ([self.audioPlayer currentTime] != [self.audioPlayer duration] && [self.audioPlayer currentTime] != 0.0f) {
    if ([self.audioPlayer currentTime] != [self.audioPlayer duration]) {
        [self meditationDidFinishWithState:[NSNumber numberWithInt:kINPROGRESS]];
    }
    else {
        [self meditationDidFinishWithState:[NSNumber numberWithInt:kMEDITATIONCOMPLETED]];
    }
    
    // Get players ready for playing again
    [self.audioPlayer setCurrentTime:0.0];
    [self.audioPlayer prepareToPlay];
    self.audioPlayer.volume = 0.5;
    self.sld_volumeControl.value = 0.5;
}

-(void)adjustVolume
{
    if (self.audioPlayer != nil)
    {
        self.audioPlayer.volume = self.sld_volumeControl.value;
    }
}


#pragma mark - shAntiUIMeditationView Delegate Methods
-(void)meditationDidStart {
    [self.btn_restart setHidden:NO];
    [self.sld_volumeControl setHidden:NO];
}

- (void)meditationDidFinishWithState:(NSNumber *)state {
    [self.btn_playPause setSelected:NO];
    
    if ([state intValue] == kMEDITATIONCOMPLETED) {
        [self.btn_playPause setImage:[UIImage imageNamed:@"Itunes-Button--Back-256--shadowed.png"] forState:UIControlStateNormal];
        [self.btn_restart setHidden:YES];
        [self.sld_volumeControl setHidden:YES];
    }
}

#pragma mark - UI Event Handlers
-(void)onDoneButtonPressed:(id)sender {
    [self stopAudio];
    [self dismissModalViewControllerAnimated:YES];
}


-(IBAction)onPlayPauseButtonPressed:(id)sender {
    // Toggle play/pause state
    [self.btn_playPause setSelected:!self.btn_playPause.selected];
    
    if (self.btn_playPause.selected) {
        // Play
        [self playAudio];
        [self.btn_restart setHidden:NO];
        [self meditationDidStart];
    }
    else {
        // Pause
        [self.btn_playPause setImage:[UIImage imageNamed:@"Itunes-Button--Play-256--shadowed.png"] forState:UIControlStateNormal];
        [self pauseAudio];
    }
}

-(IBAction)onRestartButtonPressed:(id)sender {
    // Restart meditation from beginning
    if (self.btn_playPause.selected) {
        [self rewindAudio];
    }
    else {
        [self stopAudio];
    }
}

-(IBAction)onVolumeSliderChanged:(id)sender {
    [self adjustVolume];
}


#pragma mark - AVAudioPlayer Delegate Methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
    
    if (flag == YES) {
        [self meditationDidFinishWithState:[NSNumber numberWithInt:kMEDITATIONCOMPLETED]];
    }
    else {
        [self meditationDidFinishWithState:[NSNumber numberWithInt:kINPROGRESS]];
    }
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self pauseAudio];
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self playAudio];
}

#pragma mark - Static Initializers
+ (shAntiIntroViewController*)createInstance {
    shAntiIntroViewController* vc = [[shAntiIntroViewController alloc]initWithNibName:@"shAntiIntroViewController" bundle:nil];
    [vc autorelease];
    return vc;
}

@end
