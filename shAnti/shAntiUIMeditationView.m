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
@synthesize sld_volumeControl   = m_sld_volumeControl;
@synthesize lbl_swipeSkip       = m_lbl_swipeSkip;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<shAntiUIMeditationViewDelegate>)del
{
    m_delegate = del;
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
    [self.sld_volumeControl dealloc];
    [self.lbl_swipeSkip dealloc];
    
    [self.view dealloc];
    
    [super dealloc];
}

-(IBAction) onPlayPauseButtonPressed:(id)sender {
    [self.delegate onPlayPauseButtonPressed:sender];
}

-(IBAction) onVolumeSliderChanged:(id)sender {
    [self.delegate onVolumeSliderChanged:sender];
}

@end
