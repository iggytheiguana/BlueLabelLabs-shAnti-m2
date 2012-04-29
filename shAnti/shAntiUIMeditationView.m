//
//  shAntiUIMeditationView.m
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import "shAntiUIMeditationView.h"
#import "MeditationState.h"
#import <QuartzCore/QuartzCore.h>

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
@synthesize btn_info            = m_btn_info;

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
        
        CGFloat scale = [[UIScreen mainScreen] scale]; 
        
        // Add a boarder to the image view
        //[self.iv_background.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        //[self.iv_background.layer setBorderWidth: 2.0];
        
        /*// Add shadow to the background image view
        self.iv_background.layer.shadowColor = [UIColor blackColor].CGColor;
        self.iv_background.layer.shadowOffset = CGSizeMake(0, 0);
        self.iv_background.layer.shadowOpacity = 0.75;
        self.iv_background.layer.shadowRadius = 10.0;
        self.iv_background.layer.shouldRasterize = YES;
        self.iv_background.layer.rasterizationScale = scale;
        //self.iv_background.clipsToBounds = NO;*/
        
        // Add shadow to title label
        self.lbl_titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.lbl_titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.lbl_titleLabel.layer.shadowOpacity = 0.75;   
        self.lbl_titleLabel.layer.shadowRadius = 3.0;
        self.lbl_titleLabel.layer.shouldRasterize = YES;
        self.lbl_titleLabel.layer.rasterizationScale = scale;
        //self.lbl_titleLabel.clipsToBounds = NO;
        
        /*// Add shadow to swipeToSkip label
        self.lbl_swipeSkip.layer.shadowColor = [UIColor blackColor].CGColor;
        self.lbl_swipeSkip.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.lbl_swipeSkip.layer.shadowOpacity = 0.75;   
        self.lbl_swipeSkip.layer.shadowRadius = 3.0;
        self.lbl_swipeSkip.layer.shouldRasterize = YES;
        self.lbl_swipeSkip.layer.rasterizationScale = scale;
        //self.lbl_swipeSkip.clipsToBounds = NO;
        
        // Add shadow to play/pause button
        self.btn_playPause.layer.shadowColor = [UIColor blackColor].CGColor;
        self.btn_playPause.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.btn_playPause.layer.shadowOpacity = 0.75;   
        self.btn_playPause.layer.shadowRadius = 3.0;
        self.lbl_titleLabel.layer.shouldRasterize = YES;
        self.lbl_titleLabel.layer.rasterizationScale = scale;
        //self.btn_playPause.clipsToBounds = NO;
        
        // Add shadow to the rewind button
        self.btn_restart.layer.shadowColor = [UIColor blackColor].CGColor;
        self.btn_restart.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.btn_restart.layer.shadowOpacity = 0.75;   
        self.btn_restart.layer.shadowRadius = 3.0;
        self.btn_restart.layer.shouldRasterize = YES;
        self.btn_restart.layer.rasterizationScale = scale;
        //self.btn_restart.clipsToBounds = NO;
        
        // Add shadow to the volume slider
        self.sld_volumeControl.layer.shadowColor = [UIColor blackColor].CGColor;
        self.sld_volumeControl.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.sld_volumeControl.layer.shadowOpacity = 0.75;   
        self.sld_volumeControl.layer.shadowRadius = 3.0;
        self.sld_volumeControl.layer.shouldRasterize = YES;
        self.sld_volumeControl.layer.rasterizationScale = scale;
        //self.sld_volumeControl.clipsToBounds = NO;
        
        // Add shadow to the done button
        self.btn_done.layer.shadowColor = [UIColor blackColor].CGColor;
        self.btn_done.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.btn_done.layer.shadowOpacity = 0.75;   
        self.btn_done.layer.shadowRadius = 3.0;
        self.btn_done.layer.shouldRasterize = YES;
        self.btn_done.layer.rasterizationScale = scale;
        //self.btn_done.clipsToBounds = NO;
        
        // Add shadow to the info button
        self.btn_info.layer.shadowColor = [UIColor blackColor].CGColor;
        self.btn_info.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.btn_info.layer.shadowOpacity = 0.75;   
        self.btn_info.layer.shadowRadius = 3.0;
        self.btn_info.layer.shouldRasterize = YES;
        self.btn_info.layer.rasterizationScale = scale;
        //self.btn_info.clipsToBounds = NO;*/
        
        // Setup buttons
        UIImage *doneButtonImageNormal = [UIImage imageNamed:@"button_roundrect_lightgrey.png"];
        UIImage *stretchableDoneButtonImageNormal = [doneButtonImageNormal stretchableImageWithLeftCapWidth:44 topCapHeight:22];
        [self.btn_done setBackgroundImage:stretchableDoneButtonImageNormal forState:UIControlStateNormal];
        [self.btn_done.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        
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

#pragma mark - Swipe to continue animation
- (void)textLabelAnimation {
    self.view.layer.backgroundColor = [[UIColor blackColor] CGColor];
    
    //UIImage *textImage = [UIImage imageNamed:@"SlideToUnlock.png"];
    //CGFloat textWidth = textImage.size.width;
    //CGFloat textHeight = textImage.size.height;
    CGFloat textWidth = self.lbl_swipeSkip.frame.size.width;
    CGFloat textHeight = self.lbl_swipeSkip.frame.size.height;
    
    CALayer *textLayer = [CALayer layer];
    //textLayer.contents = (id)[textImage CGImage];
    textLayer.contents = self.lbl_swipeSkip.layer.contents;
    //textLayer.frame = CGRectMake(10.0f, 215.0f, textWidth, textHeight);
    textLayer.frame = self.lbl_swipeSkip.frame;
    
    CALayer *maskLayer = [CALayer layer];
    
    // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
    // to the same value so the layer can extend the mask image.
    maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.15f] CGColor];
    maskLayer.contents = (id)[[UIImage imageNamed:@"Mask.png"] CGImage];
    
    // Center the mask image on twice the width of the text layer, so it starts to the left
    // of the text layer and moves to its right when we translate it by width.
    maskLayer.contentsGravity = kCAGravityCenter;
    //maskLayer.frame = CGRectMake(-textWidth, 0.0f, textWidth * 2, textHeight);
    maskLayer.frame = CGRectMake(0, 0.0f, textWidth * 2, textHeight);
    
    // Animate the mask layer's horizontal position
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    maskAnim.byValue = [NSNumber numberWithFloat:-textWidth];
    maskAnim.repeatCount = HUGE_VALF;
    maskAnim.duration = 2.0f;
    [maskLayer addAnimation:maskAnim forKey:@"slideAnim"];
    
    textLayer.mask = maskLayer;
    
    // OPTIONAL: Add shadow to the text layer
    textLayer.shadowColor = [UIColor blackColor].CGColor;
    textLayer.shadowOffset = CGSizeMake(0.0, 0.0);
    textLayer.shadowOpacity = 0.75;   
    textLayer.shadowRadius = 3.0;
    
    [self.view.layer addSublayer:textLayer];
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
    [self.btn_done setHidden:YES];
    [self.lbl_swipeSkip setHidden:YES];
    
    [self.delegate meditationDidStart];
}

- (void)meditationDidFinishWithState:(NSNumber *)state {
    [self.btn_playPause setSelected:NO];
    
    if ([state intValue] == kMEDITATIONCOMPLETED) {
        [self textLabelAnimation];
        [self.btn_playPause setImage:[UIImage imageNamed:@"Itunes-Button--Back-256.png"] forState:UIControlStateNormal];
        [self.btn_restart setHidden:YES];
        [self.sld_volumeControl setHidden:YES];
        [self.btn_done setHidden:NO];
    }
    
    [self.delegate meditationDidFinishWithState:state];
}

#pragma mark - UI Event Handlers
-(IBAction)onDoneButtonPressed:(id)sender {
    [self stopAudio];
    [self.delegate onDoneButtonPressed:sender];
}

-(IBAction)onInfoButtonPressed:(id)sender {
    [self pauseAudio];
    [self.delegate onInfoButtonPressed:sender];
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
        [self.btn_playPause setImage:[UIImage imageNamed:@"Itunes-Button--Play-256.png"] forState:UIControlStateNormal];
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

@end
