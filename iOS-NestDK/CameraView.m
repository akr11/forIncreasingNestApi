//
//  CameraView.m
//  iOS-NestDK
//
//  Created by Andriy Kruglyanko on 10/30/17.
//  Copyright © 2017 Nest Labs. All rights reserved.
/*  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.*/
//

#import "CameraView.h"
#import "UIColor+Custom.h"

@interface CameraView ()

@property (nonatomic, strong) UILabel *currentTempLabel;
@property (nonatomic, strong) UILabel *isAudioInputEnabledLabel;
@property (nonatomic, strong) UILabel *targetTempLabel;
@property (nonatomic, strong) UIButton *cameraNameLabel;
@property (nonatomic, strong) UILabel *currentModeLabel;
@property (nonatomic, strong) UILabel *isPublicShareEnabledLabel;
@property (nonatomic, strong) UILabel *isStreamingLabel;
@property (nonatomic, strong) UILabel *startTimeLastEventLabel;
@property (nonatomic, strong) UILabel *isVideoHistoryEnabledLabel;
    @property (nonatomic, strong) UILabel *endTimeLastEventLabel;
@property (nonatomic, strong) UILabel *lastEventUrlsExpiredTimeLabel;
    @property (nonatomic, strong) UILabel *hasSoundLabel;
    @property (nonatomic, strong) UILabel *hasMotionLabel;
    @property (nonatomic, strong) UILabel *hasPersonLabel;
    
@property (nonatomic, strong) UILabel *currentTempSuffix;
@property (nonatomic, strong) UILabel *targetTempSuffix;
@property (nonatomic, strong) UILabel *fanSuffix;

@property (nonatomic, strong) UISlider *tempSlider;
@property (nonatomic, strong) UISwitch *streamingSwitch;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, strong) Camera *currentCamera;

@property (nonatomic) BOOL isSlidingSlider;

@end

#define MODE_Y_LEVEL 45
#define CURRENT_Y_LEVEL 75
#define AUDIO_Y_LEVEL 75
#define TARGET_Y_LEVEL 130
#define PUBLIC_Y_LEVEL 105
#define STREAM_Y_LEVEL 135
#define VIDEO_HISTORY_ENABLED_Y_LEVEL 175
#define START_TIME_LAST_EVENT_Y_LEVEL 205
#define END_TIME_LAST_EVENT_Y_LEVEL 275
#define URLS_EXPIRE_TIME_Y_LEVEL 345
#define HAS_SOUND_Y_LEVEL 405
#define HAS_MOTION_Y_LEVEL 435
#define HAS_PERSON_Y_LEVEL 465

#define FAN_Y_LEVEL 185
#define TITLE_FONT_SIZE 18
#define TEMP_HEIGHT 45
#define SUFFIX_HEIGHT 20
#define SUFFIX_WIDTH 160
#define DEFAULT_PADDING 10
#define TEMP_FONT_SIZE 50
#define TEMP_MIN_VALUE 10//50
#define TEMP_MAX_VALUE 32//90

#define PLACEHOLDER_TEXT @"...°"
#define TITLE_PLACEHOLDER @"..."
#define BOLD_FONT @"HelveticaNeue-Bold"
#define REGULAR_FONT @"HelveticaNeue"
#define CURRENT_SUFFIX @"current"
#define TARGET_SUFFIX @"target"
#define FAN_TIMER_SUFFIX_ON @"fan timer (on)"
#define FAN_TIMER_SUFFIX_OFF @"fan timer (off)"
#define FAN_TIMER_SUFFIX_DISABLED @"fan timer (disabled)"
#define MODE_SUFFIX @"mode"

@implementation CameraView

@synthesize streamingTimerActive = _streamingTimerActive;
@synthesize  isAudioInputEnabled = _isAudioInputEnabled;
@synthesize  isOnline = _isOnline;
@synthesize  isPublicShareEnabled = _isPublicShareEnabled;
@synthesize  isStreaming = _isStreaming;
@synthesize  isVideoHistoryEnabled = _isVideoHistoryEnabled;
@synthesize  lastEventHasMotion = _lastEventHasMotion;
@synthesize  lastEventHasPerson = _lastEventHasPerson;
@synthesize  lastEventHasSound = _lastEventHasSound;
@synthesize  lastEventStartTime = _lastEventStartTime;
@synthesize  lastEventEndTime = _lastEventEndTime;
@synthesize  lastEventUrlsExpiredTime = _lastEventUrlsExpiredTime;
    
#pragma mark Setter Methods

/**
 * Provide the setter for the streaming timer.
 * @param streamingTimerActive The boolean of the streaming timer.
 */
- (void)setStreamingTimerActive:(BOOL)streamingTimerActive
{
    _streamingTimerActive = streamingTimerActive;
    [self updateIsStreamingLabel: streamingTimerActive ? @"YES" : @"NO" ];
}

/**
 * Provide the setter for the isAudioInputEnabled mode.
 * @param isAudioInputEnabled The isAudioInputEnabled to set isAudioInputEnabled to.
 */
- (void)setIsAudioInputEnabled:(NSString*)isAudioInputEnabled
{
    _isAudioInputEnabled = isAudioInputEnabled;
    [self updateIsAudioInputEnabledLabel:isAudioInputEnabled];
}

/**
 * Provide the setter for the isPublicShareEnabled mode.
 * @param isPublicShareEnabled The isPublicShareEnabled to set isAudioInputEnabled to.
 */
- (void)setIsPublicShareEnabled:(NSString*)isPublicShareEnabled
{
    _isPublicShareEnabled = isPublicShareEnabled;
    [self updateIsPublicShareEnabledLabel:isPublicShareEnabled];
}

/**
 * Provide the setter for the isOnline mode.
 * @param isOnline The isOnline to set isOnline to.
 */
- (void)setIsOnline:(NSString*)isOnline
{
    _isOnline = isOnline;
    [self updateCurrentModeLabel:isOnline];
}

/**
 * Provide the setter for the isStreaming mode.
 * @param isStreaming The isStreaming to set isStreaming to.
 */
- (void)setIsStreaming:(NSString*)isStreaming
{
    _isStreaming = isStreaming;
    [self updateIsStreamingLabel:isStreaming];
}

/**
 * Provide the setter for the isVideoHistoryEnabled mode.
 * @param isVideoHistoryEnabled The isVideoHistoryEnabled to set isVideoHistoryEnabled to.
 */
- (void)setIsVideoHistoryEnabled:(NSString*)isVideoHistoryEnabled
{
    _isVideoHistoryEnabled = isVideoHistoryEnabled;
    [self updateIsVideoHistoryEnabledLabel:isVideoHistoryEnabled];
}
    
/**
 * Provide the setter for the lastEventHasMotion mode.
 * @param lastEventHasMotion The lastEventHasMotion to set lastEventHasMotion to.
 */
- (void)setLastEventHasMotion:(NSString*)lastEventHasMotion
{
    _lastEventHasMotion = lastEventHasMotion;
    [self updateHasMotionLabel:lastEventHasMotion];
}

/**
 * Provide the setter for the lastEventHasPerson mode.
 * @param lastEventHasPerson The lastEventHasPerson to set lastEventHasPerson to.
 */
- (void)setLastEventHasPerson:(NSString*)lastEventHasPerson
{
    _lastEventHasPerson = lastEventHasPerson;
    [self updateHasPersonLabel:lastEventHasPerson];
}

/**
 * Provide the setter for the lastEventHasSound mode.
 * @param lastEventHasSound The lastEventHasSound to set lastEventHasSound to.
 */
- (void)setLastEventHasSound:(NSString*)lastEventHasSound
{
    _lastEventHasSound = lastEventHasSound;
    [self updateHasSoundLabel:lastEventHasSound];
}

/**
 * Provide the setter for the lastEventStartTime mode.
 * @param lastEventStartTime The lastEventStartTime to set lastEventStartTime to.
 */
- (void)setLastEventStartTime:(NSString*)lastEventStartTime
{
    _lastEventStartTime = lastEventStartTime;
    [self updateStartTimeLastEventLabel:lastEventStartTime];
}

/**
 * Provide the setter for the lastEventEndTime mode.
 * @param lastEventEndTime The lastEventEndTime to set lastEventEndTime to.
 */
- (void)setLastEventEndTime:(NSString*)lastEventEndTime
{
    _lastEventEndTime = lastEventEndTime;
    [self updateEndTimeLastEventLabel:lastEventEndTime];
}

/**
 * Provide the setter for the lastEventUrlsExpiredTime mode.
 * @param lastEventUrlsExpiredTime The lastEventUrlsExpiredTime to set lastEventUrlsExpiredTime to.
 */
- (void)setLastEventUrlsExpiredTime:(NSString*)lastEventUrlsExpiredTime
{
    _lastEventUrlsExpiredTime = lastEventUrlsExpiredTime;
    [self updatelastEventUrlsExpiredTimeLabel:lastEventUrlsExpiredTime];
}

#pragma mark View Setup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1]];
        
        // Add rounded corners
        [self.layer setCornerRadius:6.f];
        [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.layer setBorderWidth:1.f];
        [self.layer setMasksToBounds:YES];
        
        // Add all the elements
        self.cameraNameLabel = [self setupCameraNameLabel];
        
        // Setup the labels
        self.currentModeLabel = [self setupModeLabelWithY:MODE_Y_LEVEL];
        self.isAudioInputEnabledLabel = [self setupAudioLabelWithY:AUDIO_Y_LEVEL];
        self.isPublicShareEnabledLabel = [self setupPublicLabelWithY:PUBLIC_Y_LEVEL];
        self.isStreamingLabel = [self setupPublicLabelWithY:STREAM_Y_LEVEL];
        self.isVideoHistoryEnabledLabel = [self setupPublicLabelWithY:VIDEO_HISTORY_ENABLED_Y_LEVEL];
        self.startTimeLastEventLabel = [self setupPublicLabelWithY:START_TIME_LAST_EVENT_Y_LEVEL];
        self.endTimeLastEventLabel =  [self setupPublicLabelWithY:END_TIME_LAST_EVENT_Y_LEVEL];
        self.lastEventUrlsExpiredTimeLabel = [self setupPublicLabelWithY:URLS_EXPIRE_TIME_Y_LEVEL];
        self.hasSoundLabel = [self setupPublicLabelWithY:HAS_SOUND_Y_LEVEL];
        self.hasMotionLabel = [self setupPublicLabelWithY:HAS_MOTION_Y_LEVEL];
        self.hasPersonLabel = [self setupPublicLabelWithY:HAS_PERSON_Y_LEVEL];
        
        // Add the streaming switch
        self.streamingSwitch = [self setupStreamingSwitch];
        
        // Setup the loading view
        self.loadingView = [self setupLoadingView];
        
        [self.loadingView setHidden:YES];
        [self.loadingView setAlpha:0.0f];
        
        [self.activity setHidden:YES];
        [self.activity setAlpha:0.0f];
        [self.activity stopAnimating];
    }
    return self;
}

/**
 * Sets up the loading view a top the camera view.
 */
- (UIView *)setupLoadingView
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:.5f];
    
    [view.layer setCornerRadius:6.f];
    [view.layer setMasksToBounds:YES];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame), self.activity.frame.size.width, self.activity.frame.size.height)];
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [view addSubview:self.activity];
    [self addSubview:view];
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/**
 * Setup the camera name label.
 */
- (UIButton *)setupCameraNameLabel
{
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(DEFAULT_PADDING, DEFAULT_PADDING, 280, 25)];
    [cameraButton setTitle:TITLE_PLACEHOLDER forState:UIControlStateNormal];
    [cameraButton setTitleColor:[UIColor uiBlue] forState:UIControlStateNormal];
    cameraButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cameraButton.titleLabel setFont:[UIFont fontWithName:BOLD_FONT size:TITLE_FONT_SIZE]];
    [cameraButton addTarget:self action:@selector(cameraNameButtonHit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraButton];
    return cameraButton;
}

/**
 * Setup an hvac mode label with a given Y value.
 * @param yValue The yValue the label should be at.
 * @return The new UILabel.
 */
- (UILabel *)setupModeLabelWithY:(int)yValue
{
    
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEFAULT_PADDING, yValue, self.bounds.size.width - (2 * DEFAULT_PADDING), SUFFIX_HEIGHT)];
    [modeLabel setText:TITLE_PLACEHOLDER];
    [modeLabel setTextColor:[UIColor darkGrayColor]];
    [modeLabel setTextAlignment:NSTextAlignmentLeft];
    [modeLabel setFont:[UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]];
    [self addSubview:modeLabel];
    return modeLabel;
}

/**
 * Setup an audio label with a given Y value.
 * @param yValue The yValue the label should be at.
 * @return The new UILabel.
 */
- (UILabel *)setupAudioLabelWithY:(int)yValue
{
    
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEFAULT_PADDING, yValue, self.bounds.size.width - (2 * DEFAULT_PADDING), SUFFIX_HEIGHT)];
    [modeLabel setText:TITLE_PLACEHOLDER];
    [modeLabel setTextColor:[UIColor darkGrayColor]];
    [modeLabel setTextAlignment:NSTextAlignmentLeft];
    [modeLabel setFont:[UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]];
    [self addSubview:modeLabel];
    return modeLabel;
}

/**
 * Setup an public label with a given Y value.
 * @param yValue The yValue the label should be at.
 * @return The new UILabel.
 */
- (UILabel *)setupPublicLabelWithY:(int)yValue
{
    
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEFAULT_PADDING, yValue, self.bounds.size.width - (2 * DEFAULT_PADDING), SUFFIX_HEIGHT)];
    modeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    modeLabel.numberOfLines = 0;
    [modeLabel setText:TITLE_PLACEHOLDER];
    [modeLabel setTextColor:[UIColor darkGrayColor]];
    [modeLabel setTextAlignment:NSTextAlignmentLeft];
    [modeLabel setFont:[UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]];
    [self addSubview:modeLabel];
    return modeLabel;
}

/**
 * Setup a suffix label with a given Y value.
 * @param yValue The yValue the label should be at.
 * @return The new UILabel.
 */
- (UILabel *)setupSuffixLabelWithText:(NSString *)text andY:(int)yValue
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:BOLD_FONT size:TEMP_FONT_SIZE]};
    CGSize textSize = [PLACEHOLDER_TEXT sizeWithAttributes:attributes];
    
    UILabel *suffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(DEFAULT_PADDING + 5 + textSize.width, yValue + SUFFIX_HEIGHT - 3, SUFFIX_WIDTH, SUFFIX_HEIGHT)];
    [suffixLabel setText:text];
    [suffixLabel setTextColor:[UIColor darkGrayColor]];
    [suffixLabel setTextAlignment:NSTextAlignmentLeft];
    [suffixLabel setFont:[UIFont fontWithName:REGULAR_FONT size:17.f]];
    [self addSubview:suffixLabel];
    return suffixLabel;
}

/**
 * Sets up the Fan Switch
 * @return The new fan switch.
 */
- (UISwitch *)setupStreamingSwitch
{
    UISwitch *streamingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(DEFAULT_PADDING, STREAM_Y_LEVEL, 79, 50)];
    [streamingSwitch addTarget:self action:@selector(streamingDidSwitch:) forControlEvents:UIControlEventValueChanged];
    [streamingSwitch setOnTintColor:[UIColor uiBlue]];
    [self addSubview:streamingSwitch];
    return streamingSwitch;
}

#pragma mark Update Methods

/**
 * Update the current hvac mode label.
 * @param newMode The hvac mode you wish to update to.
 */
- (void)updateCurrentModeLabel:(NSString*)newMode
{
    NSString *newString = [[NSString stringWithFormat:@"%@ %@",  @" Is online:", self.isOnline] uppercaseString];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
    CGSize textSize = [newString sizeWithAttributes:attributes];
    
    [self.currentModeLabel setFrame:CGRectMake(DEFAULT_PADDING, MODE_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
    [self.currentModeLabel setText:newString];
}

/**
 * Update the fan label based on value of switch
 * @param on The value of the switch
 */
- (void)updateFanLabel:(BOOL)on
{
    NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Is streaming:", on ? @"YES" : @"NO"] ;
[self.isStreamingLabel setText:newString];/*
    if (on) {
        [self.fanSuffix setText:FAN_TIMER_SUFFIX_ON];
    } else {
        [self.fanSuffix setText:FAN_TIMER_SUFFIX_OFF];
    }*/
}

/**
 * Update the current IsAudioInputEnabled label.
 * @param newMode The IsAudioInputEnabled mode you wish to update to.
 */
- (void)updateIsAudioInputEnabledLabel:(NSString*)newMode
{
    NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Audio enabled:", self.isAudioInputEnabled] ;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
    CGSize textSize = [newString sizeWithAttributes:attributes];
    
    [self.isAudioInputEnabledLabel setFrame:CGRectMake(DEFAULT_PADDING, AUDIO_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
    [self.isAudioInputEnabledLabel setText:newString];
}

/**
 * Update the current isPublicShareEnabled label.
 * @param newMode The isPublicShareEnabled mode you wish to update to.
 */
- (void)updateIsPublicShareEnabledLabel:(NSString*)newMode
{
    NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Public share enabled:", self.isPublicShareEnabled] ;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
    CGSize textSize = [newString sizeWithAttributes:attributes];
    
    [self.isPublicShareEnabledLabel setFrame:CGRectMake(DEFAULT_PADDING, PUBLIC_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
    [self.isPublicShareEnabledLabel setText:newString];
}

/**
 * Update the current isStreaming label.
 * @param newMode The isStreaming mode you wish to update to.
 */
- (void)updateIsStreamingLabel:(NSString*)newMode
{
    NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Is streaming:", self.isStreaming] ;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
    CGSize textSize = [newString sizeWithAttributes:attributes];
    
    [self.isStreamingLabel setFrame:CGRectMake(DEFAULT_PADDING+80, STREAM_Y_LEVEL, textSize.width+10, SUFFIX_HEIGHT)];
    [self.isStreamingLabel setText:newString];
}
    
    /**
     * Update the current isVideoHistoryEnabled label.
     * @param newMode The isVideoHistoryEnabled mode you wish to update to.
     */
- (void)updateIsVideoHistoryEnabledLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Is video history enabled:", self.isVideoHistoryEnabled] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.isVideoHistoryEnabledLabel setFrame:CGRectMake(DEFAULT_PADDING, VIDEO_HISTORY_ENABLED_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
        [self.isVideoHistoryEnabledLabel setText:newString];
    }
    
    /**
     * Update the current startTimeLastEvent label.
     * @param newMode The startTimeLastEvent mode you wish to update to.
     */
- (void)updateStartTimeLastEventLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Start time last event: ", self.lastEventStartTime] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.startTimeLastEventLabel setFrame:CGRectMake(DEFAULT_PADDING, START_TIME_LAST_EVENT_Y_LEVEL, textSize.width/2, 3*SUFFIX_HEIGHT)];
        [self.startTimeLastEventLabel setText:newString];
         [self.startTimeLastEventLabel setNeedsDisplay];
    }
    
    /**
     * Update the current endTimeLastEvent label.
     * @param newMode The endTimeLastEvent mode you wish to update to.
     */
- (void)updateEndTimeLastEventLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" End time last event: ", self.lastEventEndTime] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.endTimeLastEventLabel setFrame:CGRectMake(DEFAULT_PADDING, END_TIME_LAST_EVENT_Y_LEVEL, textSize.width/2, 3*SUFFIX_HEIGHT)];
        [self.endTimeLastEventLabel setText:newString];
        [self.endTimeLastEventLabel setNeedsDisplay];
    }
    
    /**
     * Update the current lastEventUrlsExpiredTime label.
     * @param newMode The lastEventUrlsExpiredTime mode you wish to update to.
     */
- (void)updatelastEventUrlsExpiredTimeLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Last event urls expired time : ", self.lastEventUrlsExpiredTime] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.lastEventUrlsExpiredTimeLabel setFrame:CGRectMake(DEFAULT_PADDING, URLS_EXPIRE_TIME_Y_LEVEL, textSize.width/2, 3*SUFFIX_HEIGHT)];
        [self.lastEventUrlsExpiredTimeLabel setText:newString];
        [self.lastEventUrlsExpiredTimeLabel setNeedsDisplay];
    }
    
    /**
     * Update the current hasSound label.
     * @param newMode The hasSound mode you wish to update to.
     */
- (void)updateHasSoundLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Has sound last event:", self.lastEventHasSound] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.hasSoundLabel setFrame:CGRectMake(DEFAULT_PADDING, HAS_SOUND_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
        [self.hasSoundLabel setText:newString];
    }
    
    /**
     * Update the current hasMotion label.
     * @param newMode The hasMotion mode you wish to update to.
     */
- (void)updateHasMotionLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Has motion last event:", self.lastEventHasMotion] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.hasMotionLabel setFrame:CGRectMake(DEFAULT_PADDING, HAS_MOTION_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
        [self.hasMotionLabel setText:newString];
    }
    
    /**
     * Update the current hasPerson label.
     * @param newMode The hasPerson mode you wish to update to.
     */
- (void)updateHasPersonLabel:(NSString*)newMode
    {
        NSString *newString = [NSString stringWithFormat:@"%@ %@",  @" Has person last event:", self.lastEventHasPerson] ;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:TITLE_FONT_SIZE]};
        CGSize textSize = [newString sizeWithAttributes:attributes];
        
        [self.hasPersonLabel setFrame:CGRectMake(DEFAULT_PADDING, HAS_PERSON_Y_LEVEL, textSize.width, SUFFIX_HEIGHT)];
        [self.hasPersonLabel setText:newString];
    }
#pragma mark Camera Interaction Methods

/**
* Show the loading view.
 */
- (void)showLoading
{
    [self.activity startAnimating];
    [self.loadingView setHidden:NO];
    [self.activity setHidden:NO];
    
    [UIView animateWithDuration:.3f animations:^{
        [self.activity setAlpha:0.6f];
        [self.loadingView setAlpha:0.6f];
    }];
}

/**
 * Hide the loading view.
 */
- (void)hideLoading
{
    [UIView animateWithDuration:.3f animations:^{
        [self.activity setAlpha:0.0f];
        [self.loadingView setAlpha:0.0f];
    } completion:^(BOOL finished){
        [self.loadingView setHidden:YES];
        [self.activity setHidden:YES];
        [self.activity stopAnimating];
    }];
}

/**
 * Disables the entire camera view.
 */
- (void)disableView
{
    [self.loadingView setHidden:NO];
    [self.activity setHidden:YES];
    [self.loadingView setAlpha:0.4f];
}

/**
 * Enables the entire camera.
 */
- (void)enableView
{
    [self.loadingView setHidden:YES];
    [self.loadingView setAlpha:0.0f];
}

/**
 * When the fan switch is toggled.
 * @param sender The fan that was switched.
 */
- (void)streamingDidSwitch:(UISwitch *)sender
{
    [self.currentCamera setStreamingTimerActive:sender.isOn];
    [self saveCameraChange:neFAN_TIMER_ACTIVE];
    [self updateFanLabel:sender.isOn];
}

/**
 * Turn the fan on/off.
 * @param on YES if you wish to turn the fan on. NO if fan off.
 */
- (void)turnStreaming:(BOOL)on
{
    [self.streamingSwitch setOn:on];
    [self updateFanLabel:on];
    
    // Update the local state of the current camera
    [self.currentCamera setStreamingTimerActive:on];
}

/**
 * Update the camera view to represent the camera object.
 * @param camera The camera you wish to have the view represent.
 */
- (void)updateWithCamera:(Camera *)camera
{
    
    // Set the current camera
    self.currentCamera = camera;
    
    // Update the name of the camera
    [self.cameraNameLabel setTitle:camera.nameLong forState:UIControlStateNormal];
    
    
    // Update the mode of the camera
    self.isAudioInputEnabled = ((camera.isAudioInputEnabled) ? @"YES" : @"NO");
    self.isOnline = ((camera.isOnline) ? @"YES" : @"NO");
    self.isPublicShareEnabled = ((camera.isOnline) ? @"YES" : @"NO");
    self.isStreaming = ((camera.isStreaming) ? @"YES" : @"NO");
    self.isVideoHistoryEnabled = ((camera.isVideoHistoryEnabled) ? @"YES" : @"NO");
    self.lastEventStartTime = ((camera.lastEventStartTime).description);
    self.lastEventHasMotion = ((camera.lastEventHasMotion) ? @"YES" : @"NO");
    self.lastEventHasPerson = ((camera.lastEventHasPerson) ? @"YES" : @"NO");
    self.lastEventHasSound = ((camera.lastEventHasSound) ? @"YES" : @"NO");
    self.lastEventStartTime = (camera.lastEventStartTime).description;
    self.lastEventEndTime =(camera.lastEventEndTime).description;
    self.lastEventUrlsExpiredTime =  (camera.lastEventUrlsExpiredTime).description;
    self.lastEventHasSound = ((camera.lastEventHasSound) ? @"YES" : @"NO");
    self.lastEventHasMotion = ((camera.lastEventHasMotion) ? @"YES" : @"NO");
    self.lastEventHasPerson = ((camera.lastEventHasPerson) ? @"YES" : @"NO");
        [self.streamingSwitch setEnabled:YES];
        [self turnStreaming:camera.streamingTimerActive];
    
    // ensure the UIView is refresh immediately
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
}

/**
 * When the camera name button is hit.
 * @param sender The button that sent the message.
 */
- (void)cameraNameButtonHit:(UIButton *)sender
{
    [self.delegate showNextCamera];
}

/*
 * Camera was updated, save the change ONLINE!!!.
 */
- (void)saveCameraChange:(NestEndpoint)endpoint
{
    [self.delegate cameraInfoChange:self.currentCamera forEndpoint:endpoint];
}

@end
