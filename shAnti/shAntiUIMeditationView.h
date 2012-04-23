//
//  shAntiUIMeditationView.h
//  shAnti
//
//  Created by Jordan Gurrieri on 4/23/12.
//  Copyright (c) 2012 Blue Label Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol shAntiUIMeditationViewDelegate <NSObject>
@required

-(IBAction) onPlayPauseButtonPressed:(id)sender;
-(IBAction) onVolumeSliderChanged:(id)sender;

@end

@interface shAntiUIMeditationView : UIView {
    id<shAntiUIMeditationViewDelegate> m_delegate;
    
    UIView  *m_view;
    
    UIImageView     *m_iv_background;
    UILabel         *m_lbl_titleLabel;
    UILabel         *m_lbl_instructions;
    UIButton        *m_btn_playPause;
    UISlider        *m_sld_volumeControl;
    UILabel         *m_lbl_swipeSkip;
}

@property (nonatomic, assign) id<shAntiUIMeditationViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView       *view;

@property (nonatomic, retain) IBOutlet UIImageView  *iv_background;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_titleLabel;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_instructions;
@property (nonatomic, retain) IBOutlet UIButton     *btn_playPause;
@property (nonatomic, retain) IBOutlet UISlider     *sld_volumeControl;
@property (nonatomic, retain) IBOutlet UILabel      *lbl_swipeSkip;

@end
