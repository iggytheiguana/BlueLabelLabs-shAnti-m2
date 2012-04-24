//
//  shAntiUIMeditationView.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiUIMeditationView.h"

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

#pragma mark - UI Event Handlers
-(IBAction) onDoneButtonPressed:(id)sender {
    [self stopAudio];
    [self.delegate onDoneButtonPressed:sender];
}

-(IBAction) onPlayPauseButtonPressed:(id)sender {
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

-(IBAction) onRestartButtonPressed:(id)sender {
    // Restart meditation from beginning
    if (self.btn_playPause.selected) {
        [self rewindAudio];
    }
    else {
        [self stopAudio];
    }
    
    [self.delegate onRestartButtonPressed:sender];
}

-(IBAction) onVolumeSliderChanged:(id)sender {
    [self adjustVolume];
}

@end
