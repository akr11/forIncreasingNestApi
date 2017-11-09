//
//  NestCameraManager.m
//  iOS-NestDK
//
//  Created by Admin on 10/30/17.
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

#import "NestCameraManager.h"
#import "RESTManager.h"

@interface NestCameraManager ()

@property (nonatomic, strong) NSTimer *pollTimer;

@end

#define IS_AUDIO_INPUT_ENABLED @"is_audio_input_enabled"
#define IS_ONLINE @"is_online"
#define IS_PUBLIC_SHARE_ENABLED @"is_public_share_enabled"
#define IS_STREAMING @"is_streaming"
#define IS_VIDEO_HISTORY_ENABLED @"is_video_history_enabled"
#define LAST_EVENT @"last_event"
#define NAME_LONG @"name_long"
#define LAST_EVENT_START_TIME @"start_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_URLS_EXPIRE_TIME @"urls_expire_time"
#define LAST_EVENT_HAS_MOTION @"has_motion"
#define LAST_EVENT_HAS_PERSON @"has_person"
#define LAST_EVENT_HAS_SOUND @"has_sound"/*
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"
#define LAST_EVENT_END_TIME @"end_time"*/
#define CAMERA_PATH @"devices/cameras"
#define POLL_INTERVAL 30.0f

@implementation NestCameraManager

/**
 * Set up the polling timer.
 * @param camera The camera you wish to poll for. The currently selected camera
 if more than one exist in a structure.
 */
- (void)setupPollTimer:(Camera *)camera
{
    [self invalidatePollTimer];
    
    // Enable the timer on the main thread and pass the thermostat
    //   as a parameter (userInfo)
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLL_INTERVAL
                                                          target:self
                                                        selector:@selector(pollCamera:)
                                                        userInfo:camera
                                                         repeats:YES];
    });
}

/**
 * Callback from the poll timer, gets the current state of the camera.
 * @param camera The poll NSTimer object.
 */
- (void)pollCamera:(NSTimer*)theTimer
{
    [self getStateForCamera:[theTimer userInfo]];
}

/**
 * Gets the current state of a camera and updates the display.
 * @param camera The camera being checked for the current state.
 */
- (void)getStateForCamera:(Camera *)camera
{
    
    [[RESTManager sharedManager] getData:[NSString stringWithFormat:@"devices/cameras/%@/", camera.cameraId]
                                 success:^(NSDictionary *responseJSON) {
                                     NSLog(@"devices/cameras/%@/", camera.cameraId);
                                     [self updateCamera:camera forStructure:responseJSON];
                                     [self.delegate errorDisplay:[responseJSON objectForKey:@"error"]];
                                     
                                 } redirect:^(NSHTTPURLResponse *responseURL) {
                                     
                                     // If a redirect was thrown, make another call using the redirect URL
                                     self.redirectURL = [NSString stringWithFormat:@"%@", [responseURL URL]];
                                     
                                     [[RESTManager sharedManager] getDataRedirect:self.redirectURL
                                                                          success:^(NSDictionary *responseJSON) {
                                                                              
                                                                              [self updateCamera:camera forStructure:responseJSON];
                                                                              [self.delegate errorDisplay:[responseJSON objectForKey:@"error"]];
                                                                              
                                                                          } failure:^(NSError *error) {
                                                                              NSLog(@"NestCameraManager Redirect Error: %@", error);
                                                                          }];
                                     
                                 } failure:^(NSError *error) {
                                     NSLog(@"NestCameraManager Error: %@", error);
                                     
                                 }];
    
}

/**
 * Parse camera structure and put it in the camera object.
 * Then send the updated object to the delegate.
 * @param camera The thermostat you wish to update.
 * @param structure The structure you wish to update the camera with.
 */
- (void)updateCamera:(Camera *)camera forStructure:(NSDictionary *)structure
{
   if ([structure objectForKey:IS_ONLINE]) {
        camera.isOnline = [[structure objectForKey:IS_ONLINE] boolValue];
    }
    if ([structure objectForKey:IS_AUDIO_INPUT_ENABLED]) {
        camera.isAudioInputEnabled = [[structure objectForKey:IS_AUDIO_INPUT_ENABLED] boolValue];
    }
    if ([structure objectForKey:IS_PUBLIC_SHARE_ENABLED]) {
        camera.isPublicShareEnabled = [[structure objectForKey:IS_PUBLIC_SHARE_ENABLED] boolValue];
    }
    if ([structure objectForKey:IS_STREAMING]) {
        camera.isStreaming = [[structure objectForKey:IS_STREAMING] boolValue];
    }
    
    if ([structure objectForKey:IS_VIDEO_HISTORY_ENABLED]) {
        camera.isVideoHistoryEnabled = [[structure objectForKey:IS_VIDEO_HISTORY_ENABLED] boolValue];
    }
    
    if ([structure objectForKey:LAST_EVENT] && [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_HAS_MOTION]) {
        camera.lastEventHasMotion = [[[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_HAS_MOTION] boolValue];
    }
    
    if ([structure objectForKey:LAST_EVENT] && [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_HAS_PERSON]) {
        camera.lastEventHasPerson = [[[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_HAS_PERSON] boolValue];
    }
    
    if ([structure objectForKey:LAST_EVENT] && [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_HAS_SOUND]) {
        camera.lastEventHasSound = [[[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_HAS_SOUND] boolValue];
    }
    
    if ([structure objectForKey:LAST_EVENT] && [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_START_TIME]) {
        NSString *s1 =  [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_START_TIME];
        //2017-10-31T11:39:19.511Z
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *date = [dateFormatter dateFromString:s1];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSZ"];
        NSString *s2 = [dateFormatter stringFromDate:date];
        
        /*
        NSString *finalDate = @"2014-10-15";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        [dateFormatter setDateFormat:@"EE, d MMM, YYYY"];
        return [dateFormatter stringFromDate:date];
        */
        camera.lastEventStartTime = date;
        
    }
    if ([structure objectForKey:LAST_EVENT] && [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_END_TIME]) {
        NSString *s1 =  [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_END_TIME];
        //2017-10-31T11:39:19.511Z
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *date = [dateFormatter dateFromString:s1];
        camera.lastEventEndTime = date;
        
    }
    if ([structure objectForKey:LAST_EVENT] && [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_URLS_EXPIRE_TIME]) {
        NSString *s1 =  [[structure objectForKey:LAST_EVENT] objectForKey:LAST_EVENT_URLS_EXPIRE_TIME] ;
        //2017-10-31T11:39:19.511Z
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *date = [dateFormatter dateFromString:s1];
        camera.lastEventUrlsExpiredTime = date;
        
    }
    if ([structure objectForKey:NAME_LONG]) {
        camera.nameLong = [structure objectForKey:NAME_LONG];
    }
    
    [self.delegate cameraValuesChanged:camera];
}

/**
 * Sets thermostat values via the Nest API.
 * @param thermostat The thermostat you wish to update.
 * @param endpoint The endpoint you wish to update.
 */
- (void)saveChangesForCamera:(Camera *)camera forEndpoint:(NestEndpoint)endpoint
{
    
    NSData *jsonString;
    
    if (camera.isStreaming == true) {
        jsonString = [NSJSONSerialization dataWithJSONObject:@{ IS_STREAMING : @YES }
                                                     options:kNilOptions
                                                       error:nil];
    } else {
        jsonString = [NSJSONSerialization dataWithJSONObject:@{ IS_STREAMING : @NO }
                                                     options:kNilOptions
                                                       error:nil];
        
    }
    
    // Make the write call for the specified camera
    [[RESTManager sharedManager] setData:[NSString stringWithFormat:@"devices/cameras/%@/", camera.cameraId]
                              withValues:jsonString
                                 success:^(NSDictionary *responseJSON) {
                                     
                                     [self.delegate errorDisplay:[responseJSON objectForKey:@"error"]];
                                     
                                 } redirect:^(NSHTTPURLResponse *responseURL) {
                                     
                                     // If a redirect was thrown, make another call using the redirect URL
                                     self.redirectURL = [NSString stringWithFormat:@"%@", [responseURL URL]];
                                     
                                     [[RESTManager sharedManager] setDataRedirect:self.redirectURL
                                                                       withValues:jsonString
                                                                          success:^(NSDictionary *responseJSON) {
                                                                              
                                                                              [self.delegate errorDisplay:[responseJSON objectForKey:@"error"]];
                                                                              
                                                                          } failure:^(NSError *error) {
                                                                              NSLog(@"NestCameraManager Redirect Error: %@", error);
                                                                          }];
                                     
                                 } failure:^(NSError *error) {
                                     NSLog(@"NestCameraManager Error: %@", error);
                                 }];
    
}

/**
 * Invalidate (turn off) the read polling timer
 */
- (void)invalidatePollTimer
{
    if ([self.pollTimer isValid]) {
        [self.pollTimer invalidate];
        self.pollTimer = nil;
    }
}

@end
