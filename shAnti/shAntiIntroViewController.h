//
//  shAntiIntroViewController.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/29/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>

@interface shAntiIntroViewController : UIViewController < AVAudioPlayerDelegate > {
    UILabel         *m_lbl_titleLabel;
    UILabel         *m_lbl_instructionLabel;
    UIButton        *m_btn_playPause;
    UIButton        *m_btn_restart;
    UISlider        *m_sld_volumeControl;
    
    AVAudioPlayer   *m_audioPlayer;
}

@property (nonatomic, retain) IBOutlet UILabel      *lbl_titleLabel;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_instructionLabel;
@property (nonatomic, retain) IBOutlet UIButton     *btn_playPause;
@property (nonatomic, retain) IBOutlet UIButton     *btn_restart;
@property (nonatomic, retain) IBOutlet UISlider     *sld_volumeControl;

@property (nonatomic, retain) AVAudioPlayer         *audioPlayer;

-(IBAction)onPlayPauseButtonPressed:(id)sender;
-(IBAction)onRestartButtonPressed:(id)sender;
-(IBAction)onVolumeSliderChanged:(id)sender;

+(shAntiIntroViewController*)createInstance;

@end
