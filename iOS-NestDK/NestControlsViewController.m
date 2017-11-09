/**
 *  Copyright 2014 Nest Labs Inc. All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import "NestConnectViewController.h"
#import "NestControlsViewController.h"
#import "ThermostatView.h"
#import "NestThermostatManager.h"
#import "NestStructureManager.h"
#import "NestAuthManager.h"
#import "UIColor+Custom.h"
#import "CameraView.h"
#import "NestCameraManager.h"

@interface NestControlsViewController () <NestThermostatManagerDelegate, NestStructureManagerDelegate, ThermostatViewDelegate, NestAuthManagerDelegate, NestCameraManagerDelegate, CameraViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) ThermostatView *thermostatView;
@property (nonatomic, strong) Thermostat *currentThermostat;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) Camera *currentCamera;

@property (nonatomic) NSInteger numberOfThermostats;
@property (nonatomic) NSInteger currentThermostatIndex;
@property (nonatomic) NSInteger numberOfCameras;
@property (nonatomic) NSInteger currentCameraIndex;

@property (nonatomic, strong) NestThermostatManager *nestThermostatManager;
@property (nonatomic, strong) NestCameraManager *nestCameraManager;
@property (nonatomic, strong) NestStructureManager *nestStructureManager;
@property (nonatomic, strong) NestAuthManager *nestAuthManager;

@property (nonatomic, strong) NSDictionary *currentStructure;

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) UIButton *deauthButton;

@end

@implementation NestControlsViewController

#pragma mark - View Configuration Methods

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Add the scroll view
    [self setupScrollView];

    // Add the ThermostatView
    [self setupThermostatView];
    
    // Add the CameraView
    [self setupCameraView];
    
    // Add the tap to switch label
    [self addTapToSwitchLabel];
    
    // Add the error view
    [self setupErrorView];
    
    // Add the deauth button
    [self addDeauthButton];
}

/**
 * Sets up the tap to switch label.
 */
- (void)addTapToSwitchLabel
{
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 255, 300, 25)];
    [self.statusLabel setText:@""];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.statusLabel setTextColor:[UIColor darkGrayColor]];
    [self.statusLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:22.f]];
    [self.scrollView addSubview:self.statusLabel];
    
}

/**
 * Sets up the scroll view.
 */
- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.scrollView setBounces:YES];
    [self.scrollView setAlwaysBounceVertical:YES];
    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [self.scrollView setContentSize:CGSizeMake( self.view.frame.size.width, 955)];
    [self.view addSubview:self.scrollView];
}


/**
 * Sets up the thermostat view.
 */
- (void)setupThermostatView
{
    self.thermostatView = [[ThermostatView alloc] initWithFrame:CGRectMake(10, 10, 300, 235)];
    [self.thermostatView setDelegate:self];
    [self.scrollView addSubview:self.thermostatView];
}

/**
 * Sets up the camera view.
 */
- (void)setupCameraView
{
    self.cameraView = [[CameraView alloc] initWithFrame:CGRectMake(10, 350, 300, 495)];
    [self.cameraView setDelegate:self];
    [self.scrollView addSubview:self.cameraView];
}

/**
 * Sets up the error view.
 */
- (void)setupErrorView
{
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 280, 280, 60)];
    [self.errorLabel setText:@""];
    [self.errorLabel setTextAlignment:NSTextAlignmentCenter];
    [self.errorLabel setTextColor:[UIColor redColor]];
    [self.errorLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.f]];
    [self.errorLabel setNumberOfLines:0];
    [self.errorLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.scrollView addSubview:self.errorLabel];
}

/**
 * Sets up the deauthorize button.
 */
- (UIButton *)addDeauthButton
{
    self.deauthButton = [UIButton buttonWithType:UIButtonTypeSystem];
                         
    [self.deauthButton setFrame:CGRectMake(10, 850, 300, 45)];
    [self.deauthButton setTitle:@"Deauthorize Connection" forState:UIControlStateNormal];
    [self.deauthButton setTitleColor:[UIColor uiBlue] forState:UIControlStateNormal];
    [self.deauthButton setTitleColor:[UIColor uiBlueSelected] forState:UIControlStateHighlighted];
    [self.deauthButton setBackgroundColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1]];

    [self.deauthButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.deauthButton.layer setCornerRadius:5.f];
    [self.deauthButton.layer setBorderWidth:1.f];
    [self.deauthButton.layer setMasksToBounds:YES];
    
    [self.deauthButton addTarget:self
                          action:@selector(deauthorize:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.deauthButton setUserInteractionEnabled:YES];
    
    [self.scrollView addSubview:self.deauthButton];
    return self.deauthButton;

}

/**
 * Deauthorizes the existing Works with Nest connection,
 *   performs clean up and brings back the Connect view
 */
- (void)deauthorize:(UIButton *)sender
{
    
    // Deauthorize the connection and delete saved data
    [self.nestAuthManager deauthorizeConnection];
    
    // Stop the read polling
    [self.nestThermostatManager invalidatePollTimer];
    
    // Remove the current view and bring up the Connect view
    [self.navigationController popViewControllerAnimated:YES];
    NestConnectViewController *ncvc = [[NestConnectViewController alloc] init];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:ncvc] animated:YES];
    
}


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the title of the nav bar
    self.title = @"Nest Controls";
    
    // Set the current thermostat index to 0
    self.currentThermostatIndex = 0;
    self.currentCameraIndex = 0;
    
    // Get the initial structure
    self.nestStructureManager = [[NestStructureManager alloc] init];
    [self.nestStructureManager setDelegate:self];
    [self.nestStructureManager initialize];
    
    // Get the initial thermostat
    self.nestThermostatManager = [[NestThermostatManager alloc] init];
    [self.nestThermostatManager setDelegate:self];
    
    // Get the initial camera
    self.nestCameraManager = [[NestCameraManager alloc] init];
    [self.nestCameraManager setDelegate:self];
    
    // Get the auth manager
    self.nestAuthManager = [[NestAuthManager alloc] init];
    [self.nestAuthManager setDelegate:self];
    
    [self.thermostatView showLoading];
    [self.cameraView showLoading];
    
}

#pragma mark - NestStructureManagerDelegate Methods

/**
 * Called from NestStructureManagerDelegate, lets the
 * controller know the structure has changed.
 * @param structure The updated structure.
 */
- (void)structureUpdated:(NSDictionary *)structure
{
    self.currentStructure = structure;
    
    if ([self.currentStructure objectForKey:@"thermostats"]) {
        
        self.numberOfThermostats = [[self.currentStructure objectForKey:@"thermostats"] count];
        self.currentThermostat = [[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:self.currentThermostatIndex];
        [self subscribeToThermostat:self.currentThermostat];
        
        [self.thermostatView enableView];
        [self.statusLabel setText:@"Tap title to switch devices"];
        
    } else {
        [self.thermostatView disableView];
        [self.statusLabel setText:@"You don't have any devices"];
    }
    
    if ([self.currentStructure objectForKey:@"cameras"]) {
        self.numberOfCameras = [[self.currentStructure objectForKey:@"cameras"] count];
        self.currentCamera = [[self.currentStructure objectForKey:@"cameras"] objectAtIndex:self.currentCameraIndex];
        [self subscribeToCamera:self.currentCamera];
        
        [self.cameraView enableView];
        [self.statusLabel setText:@"Tap title to switch devices"];
    }
    
    
}

#pragma mark - ThermostatViewDelegate Methods

/**
 * Called from the ThermostatViewDelegate, lets the controller know
 * thermostat info has changed.
 * @param thermostat The updated thermostat object from ThermostatView.
 */
- (void)thermostatInfoChange:(Thermostat *)thermostat forEndpoint:(NestEndpoint)endpoint
{
    [self.nestThermostatManager saveChangesForThermostat:thermostat forEndpoint:endpoint];
}

/**
 * Scrolls through the thermostats.
 */
- (void)showNextThermostat
{
    if (self.currentThermostatIndex >= self.numberOfThermostats - 1) {
        self.currentThermostatIndex = 0;
    } else {
        self.currentThermostatIndex ++;
    }
    
    [self subscribeToThermostat:[[self.currentStructure objectForKey:@"thermostats"] objectAtIndex:self.currentThermostatIndex]];
}
    
#pragma mark - CameraViewDelegate Methods
    
    /**
     * Called from the CameraViewDelegate, lets the controller know
     * camera info has changed.
     * @param camera The updated camera object from CameraView.
     */
- (void)cameraInfoChange:(Camera *)camera forEndpoint:(NestEndpoint)endpoint
    {
        [self.nestCameraManager saveChangesForCamera:camera forEndpoint:endpoint];
    }
    
    /**
     * Scrolls through the cameras.
     */
- (void)showNextCamera
    {
        if (self.currentCameraIndex >= self.numberOfCameras - 1) {
            self.currentCameraIndex = 0;
        } else {
            self.currentCameraIndex ++;
        }
        
        [self subscribeToCamera:[[self.currentStructure objectForKey:@"cameras"] objectAtIndex:self.currentCameraIndex]];
    }

#pragma mark - Private Methods

/**
 * Setup the communication between thermostatView and thermostatControl.
 * @param thermostat The thermostat you wish to subscribe to.
 */
- (void)subscribeToThermostat:(Thermostat *)thermostat
{
    // See if the structure has any thermostats --
    if (thermostat) {
        
        // Update the current thermostats
        self.currentThermostat = thermostat;

        [self.thermostatView showLoading];

        // Load information for just the first thermostat
        [self.nestThermostatManager getStateForThermostat:thermostat];
        
        // Create the timer for READ polling
        [self.nestThermostatManager setupPollTimer:thermostat];
        
    }
    
}

/**
 * Setup the communication between thermostatView and thermostatControl.
 * @param thermostat The thermostat you wish to subscribe to.
 */
- (void)subscribeToCamera:(Camera *)camera
{
    // See if the structure has any thermostats --
    if (camera) {
        
        // Update the current thermostats
        self.currentCamera = camera;
        
        [self.cameraView showLoading];
        
        // Load information for just the first thermostat
        [self.nestCameraManager getStateForCamera:camera];
        
        // Create the timer for READ polling
        [self.nestCameraManager setupPollTimer:camera];
        
    }
    
}

#pragma mark - NestThermostatManagerDelegate Methods

/**
 * Called from NestThermostatManagerDelegate, lets us know thermostat 
 * information has been updated online.
 * @param thermostat The updated thermostat object.
 */
- (void)thermostatValuesChanged:(Thermostat *)thermostat
{
    [self.thermostatView hideLoading];

    if ([thermostat.thermostatId isEqualToString:[self.currentThermostat thermostatId]]) {
        [self.thermostatView updateWithThermostat:thermostat];
    }

}

/**
 * Display the error in the app
 * @param error The error returned by the Nest API, nil if no error
 */
- (void)errorDisplay:(NSError *)error
{
    if (error)
        [self.errorLabel setText:[NSString stringWithFormat:@"Error! %@", error]];
    else
        [self.errorLabel setText:nil];
}

#pragma mark - NestCameraManagerDelegate

/**
 * Called from NestThermostatManagerDelegate, lets us know thermostat
 * information has been updated online.
 * @param thermostat The updated thermostat object.
 */
- (void)cameraValuesChanged:(Camera *)camera
{
    [self.cameraView hideLoading];
    
    if ([camera.cameraId isEqualToString:[self.currentCamera cameraId]]) {
        [self.cameraView updateWithCamera:camera];
    }
    
}

/**
 * Display the error in the app
 * @param error The error returned by the Nest API, nil if no error
 */
/*
- (void)errorDisplay:(NSError *)error
{
    if (error)
        [self.errorLabel setText:[NSString stringWithFormat:@"Error! %@", error]];
    else
        [self.errorLabel setText:nil];
}*/

@end
