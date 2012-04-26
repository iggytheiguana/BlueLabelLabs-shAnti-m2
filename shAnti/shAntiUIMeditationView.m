//
//  shAntiUIMeditationView.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiUIMeditationView.h"
#import "MeditationState.h"
#import "QuartzCore/CALayer.h"

@implementation shAntiUIMeditationView

@synthesize view                = m_view;
@synthesize iv_background       = m_iv_background;
@synthesize lbl_titleLabel      = m_lbl_titleLabel;
@synthesize lbl_instructions    = m_lbl_instructions;
@synthesize btn_playPause       = m_btn_playPause;
@synthesize btn_restart         = m_btn_restart;
@synthesize sld_volumeControl   = m_sld_volumeControl;
@synthesize lbl_swipeSkip       = m_lbl_swipeSkip;
@synthesize audioPlayer         = m_audioPlayer;
@synthesize btn_done            = m_btn_done;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<shAntiUIMeditationViewDelegate>)del
{
    m_delegate = del;
}

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

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"shAntiUIMeditationView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load shAntiUIMeditationView file.\n");
        }
        
        [self addSubview:self.view];
        
        // Add a boarder to the image view
        //[self.iv_background.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        //[self.iv_background.layer setBorderWidth: 2.0];
        
        // Add shadow to the image view
        self.iv_background.layer.shadowColor = [UIColor blackColor].CGColor;
        self.iv_background.layer.shadowOffset = CGSizeMake(0, 0);
        self.iv_background.layer.shadowOpacity = 0.75;
        self.iv_background.layer.shadowRadius = 10.0;
        self.iv_background.clipsToBounds = NO;

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [self.iv_background dealloc];
    [self.lbl_titleLabel dealloc];
    [self.lbl_instructions dealloc];
    [self.btn_playPause dealloc];
    [self.btn_restart dealloc];
    [self.sld_volumeControl dealloc];
    [self.lbl_swipeSkip dealloc];
    
    [self.btn_done dealloc];
    
    [super dealloc];
}

#pragma mark - Audio Action Methods
-(void)playAudio
{    
    [self.audioPlayer play];
    [self meditationDidStart];
}

-(void)pauseAudio
{
    [self.audioPlayer pause];
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
        [self meditationDidFinishWithState:[NSNumber numberWithInt:kCOMPLETED]];
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
    [self.delegate meditationDidStart];
}

- (void)meditationDidFinishWithState:(NSNumber *)state {
    [self.delegate meditationDidFinishWithState:state];
}

#pragma mark - UI Event Handlers
-(IBAction)onDoneButtonPressed:(id)sender {
    [self stopAudio];
    [self.delegate onDoneButtonPressed:sender];
}

-(IBAction)onPlayPauseButtonPressed:(id)sender {
    // Toggle play/pause state
    [self.btn_playPause setSelected:!self.btn_playPause.selected];
    
    if (self.btn_playPause.selected) {
        [self playAudio];
    }
    else {
        [self pauseAudio];
    }
    
    [self.delegate onPlayPauseButtonPressed:sender];
}

-(IBAction)onRestartButtonPressed:(id)sender {
    // Restart meditation from beginning
    if (self.btn_playPause.selected) {
        [self rewindAudio];
    }
    else {
        [self stopAudio];
    }
    
    [self.delegate onRestartButtonPressed:sender];
}

-(IBAction)onVolumeSliderChanged:(id)sender {
    [self adjustVolume];
}


#pragma mark - AVAudioPlayer Delegate Methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag == YES) {
        [self meditationDidFinishWithState:[NSNumber numberWithInt:kCOMPLETED]];
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

@end
