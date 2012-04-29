//
//  shAntiUIMeditationView.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>

@protocol shAntiUIMeditationViewDelegate <NSObject>
@required

-(void)meditationDidStart;
-(void)meditationDidFinishWithState:(NSNumber *)state;
-(IBAction)onPlayPauseButtonPressed:(id)sender;
-(IBAction)onRestartButtonPressed:(id)sender;
-(IBAction)onDoneButtonPressed:(id)sender;
-(IBAction)onInfoButtonPressed:(id)sender;

@end

@interface shAntiUIMeditationView : UIView < AVAudioPlayerDelegate > {
    id<shAntiUIMeditationViewDelegate> m_delegate;
    
    UIView  *m_view;
    
    UIImageView     *m_iv_background;
    UILabel         *m_lbl_titleLabel;
    UILabel         *m_lbl_instructions;
    UIButton        *m_btn_playPause;
    UIButton        *m_btn_restart;
    UISlider        *m_sld_volumeControl;
    UILabel         *m_lbl_swipeSkip;
    
    AVAudioPlayer   *m_audioPlayer;
    
    UIButton        *m_btn_done;
    UIButton        *m_btn_info;
}

@property (nonatomic, assign) id<shAntiUIMeditationViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView       *view;

@property (nonatomic, retain) IBOutlet UIImageView  *iv_background;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_titleLabel;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_instructions;
@property (nonatomic, retain) IBOutlet UIButton     *btn_playPause;
@property (nonatomic, retain) IBOutlet UIButton     *btn_restart;
@property (nonatomic, retain) IBOutlet UISlider     *sld_volumeControl;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_swipeSkip;

@property (nonatomic, retain) AVAudioPlayer         *audioPlayer;

@property (nonatomic, retain) IBOutlet UIButton     *btn_done;
@property (nonatomic, retain) IBOutlet UIButton     *btn_info;


-(void)loadAudioWithFile:(NSURL*)url;
-(void)playAudio;
-(void)pauseAudio;
-(void)restartAudio;
-(void)stopAudio;
-(void)adjustVolume;

@end
