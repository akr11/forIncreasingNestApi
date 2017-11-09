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

#import "NestThermostatManager.h"
#import "RESTManager.h"

@interface NestThermostatManager ()

@property (nonatomic, strong) NSTimer *pollTimer;

@end

#define FAN_TIMER_ACTIVE @"fan_timer_active"
#define HAS_FAN @"has_fan"
#define TARGET_TEMPERATURE_F @"target_temperature_f"
#define AMBIENT_TEMPERATURE_F @"ambient_temperature_f"
#define TARGET_TEMPERATURE_C @"target_temperature_c"
#define AMBIENT_TEMPERATURE_C @"ambient_temperature_c"
#define HVAC_MODE @"hvac_mode"
#define NAME_LONG @"name_long"
#define THERMOSTAT_PATH @"devices/thermostats"
#define POLL_INTERVAL 30.0f

@implementation NestThermostatManager

/**
 * Set up the polling timer.
 * @param thermostat The thermostat you wish to poll for. The currently selected thermostat
    if more than one exist in a structure.
 */
- (void)setupPollTimer:(Thermostat *)thermostat
{
    [self invalidatePollTimer];
    
    // Enable the timer on the main thread and pass the thermostat
    //   as a parameter (userInfo)
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLL_INTERVAL
                                                          target:self
                                                        selector:@selector(pollThermostat:)
                                                        userInfo:thermostat
                                                         repeats:YES];
    });
}

/**
 * Callback from the poll timer, gets the current state of the thermostat.
 * @param theTimer The poll NSTimer object.
 */
- (void)pollThermostat:(NSTimer*)theTimer
{
    [self getStateForThermostat:[theTimer userInfo]];
}

/**
 * Gets the current state of a thermostat and updates the display.
 * @param thermostat The thermostat being checked for the current state.
 */
- (void)getStateForThermostat:(Thermostat *)thermostat
{
    
    [[RESTManager sharedManager] getData:[NSString stringWithFormat:@"devices/thermostats/%@/", thermostat.thermostatId]
                                 success:^(NSDictionary *responseJSON) {
                                     NSLog(@"devices/thermostats/%@/", thermostat.thermostatId);
        [self updateThermostat:thermostat forStructure:responseJSON];
        [self.delegate errorDisplay:[responseJSON objectForKey:@"error"]];
        
    } redirect:^(NSHTTPURLResponse *responseURL) {
        
        // If a redirect was thrown, make another call using the redirect URL
        self.redirectURL = [NSString stringWithFormat:@"%@", [responseURL URL]];
        
        [[RESTManager sharedManager] getDataRedirect:self.redirectURL
                                             success:^(NSDictionary *responseJSON) {
            
            [self updateThermostat:thermostat forStructure:responseJSON];
            [self.delegate errorDisplay:[responseJSON objectForKey:@"error"]];
            
        } failure:^(NSError *error) {
            NSLog(@"NestThermostatManager Redirect Error: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"NestThermostatManager Error: %@", error);
        
    }];
    
}

/**
 * Parse thermostat structure and put it in the thermostat object.
 * Then send the updated object to the delegate.
 * @param thermostat The thermostat you wish to update.
 * @param structure The structure you wish to update the thermostat with.
 */
- (void)updateThermostat:(Thermostat *)thermostat forStructure:(NSDictionary *)structure
{
    if ([structure objectForKey:AMBIENT_TEMPERATURE_F]) {
        thermostat.ambientTemperatureF = [[structure objectForKey:AMBIENT_TEMPERATURE_F] integerValue];
    }
    if ([structure objectForKey:TARGET_TEMPERATURE_F]) {
        thermostat.targetTemperatureF = [[structure objectForKey:TARGET_TEMPERATURE_F] integerValue];
    }
    if ([structure objectForKey:AMBIENT_TEMPERATURE_C]) {
        thermostat.ambientTemperatureC = [[structure objectForKey:AMBIENT_TEMPERATURE_C] integerValue];
    }
    if ([structure objectForKey:TARGET_TEMPERATURE_C]) {
        thermostat.targetTemperatureC = [[structure objectForKey:TARGET_TEMPERATURE_C] integerValue];
    }
    
    if ([structure objectForKey:HVAC_MODE]) {
        thermostat.hvacMode = [structure objectForKey:HVAC_MODE];
    }
    
    if ([structure objectForKey:HAS_FAN]) {
        thermostat.hasFan = [[structure objectForKey:HAS_FAN] boolValue];

    }
    if ([structure objectForKey:FAN_TIMER_ACTIVE]) {
        thermostat.fanTimerActive = [[structure objectForKey:FAN_TIMER_ACTIVE] boolValue];

    }
    if ([structure objectForKey:NAME_LONG]) {
        thermostat.nameLong = [structure objectForKey:NAME_LONG];
    }
    
    [self.delegate thermostatValuesChanged:thermostat];
}

/**
 * Sets thermostat values via the Nest API.
 * @param thermostat The thermostat you wish to update.
 * @param endpoint The endpoint you wish to update.
 */
- (void)saveChangesForThermostat:(Thermostat *)thermostat forEndpoint:(NestEndpoint)endpoint
{
    
    NSData *jsonString;
    NSNumber *temperature;
    
    // Build the JSON request based on the field that was changed
    switch(endpoint)
    {
        case neFAN_TIMER_ACTIVE:
            if (thermostat.hasFan) {
                if (thermostat.fanTimerActive) {
                    jsonString = [NSJSONSerialization dataWithJSONObject:@{ FAN_TIMER_ACTIVE : @YES }
                                                                 options:kNilOptions
                                                                   error:nil];
                }
                else {
                    jsonString = [NSJSONSerialization dataWithJSONObject:@{ FAN_TIMER_ACTIVE : @NO }
                                                                 options:kNilOptions
                                                                   error:nil];
                }
            }
            break;
        case neTARGET_TEMPERATURE_F:
            temperature = [NSNumber numberWithInteger:thermostat.targetTemperatureF];
            jsonString = [NSJSONSerialization dataWithJSONObject:@{ TARGET_TEMPERATURE_F : temperature }
                                                         options:kNilOptions
                                                           error:nil];
            break;
        case neTARGET_TEMPERATURE_C:
            temperature = [NSNumber numberWithInteger:thermostat.targetTemperatureC];
            jsonString = [NSJSONSerialization dataWithJSONObject:@{ TARGET_TEMPERATURE_C : temperature }
                                                         options:kNilOptions
                                                           error:nil];
            break;
        default:
            break;
    }
    
    // Make the write call for the specified thermostat
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonString options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
    }
    else {
        NSLog(@"Array: %@", jsonArray);
    }
    [[RESTManager sharedManager] setData:[NSString stringWithFormat:@"devices/thermostats/%@/", thermostat.thermostatId]
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
            NSLog(@"NestThermostatManager Redirect Error: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"NestThermostatManager Error: %@", error);
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
