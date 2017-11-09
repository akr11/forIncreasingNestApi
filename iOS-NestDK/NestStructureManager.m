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

#import "NestStructureManager.h"
#import "Thermostat.h"
#import "NestAuthManager.h"
#import "RESTManager.h"
#import "Camera.h"

@implementation NestStructureManager

/**
 * Gets the entire structure and converts it to
 * thermostat objects and returns it as a dictionary.
 */
- (void)initialize
{
    
    [[RESTManager sharedManager] getData:@"structures"
                                 success:^(NSDictionary *responseJSON) {
                                     
                                     [self parseStructure:responseJSON];
                                     
                                 } redirect:^(NSHTTPURLResponse *responseURL) {
                                     
                                     // If a redirect was thrown, make another call using the redirect URL
                                     self.redirectURL = [NSString stringWithFormat:@"%@", [responseURL URL]];
                                     
                                     [[RESTManager sharedManager] getDataRedirect:self.redirectURL
                                                                          success:^(NSDictionary *responseJSON) {
                                                                              
                                                                              [self parseStructure:responseJSON];
                                                                              
                                                                          } failure:^(NSError *error) {
                                                                              NSLog(@"NestStructureManager Redirect Error: %@", error);
                                                                          }];
                                     
                                 } failure:^(NSError *error) {
                                     NSLog(@"NestStructureManager Error: %@", error);
                                 }];
    
}

/**
 * Parse the structure and send it back to the delegate
 * @param The structure you want to parse.
 */
- (void)parseStructure:(NSDictionary *)structure
{
    NSArray *thermostats = [self thermostatsForStructure:structure];
    NSArray *cameras = [self camerasForStructure:structure];
    
    NSMutableDictionary *returnStructure = [[NSMutableDictionary alloc] init];
    
    if (thermostats) {
        [returnStructure setObject:thermostats forKey:@"thermostats"];
    }
    if (cameras) {
        [returnStructure setObject:cameras forKey:@"cameras"];
    }
    
    [self.delegate structureUpdated:returnStructure];
    
}

/**
 * Create new thermostats for the given structure
 * @param The structure you want to create thermostats for
 * @return The list of thermostats in the structure in an NSArray
 */
- (NSArray *)thermostatsForStructure:(NSDictionary *)structure
{
    NSString *structureId = [[structure allKeys] objectAtIndex:0];
    NSArray *thermostatIds = [[structure objectForKey:structureId] objectForKey:@"thermostats"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    if (!thermostatIds || [thermostatIds count] == 0) {
        return nil;
    } else {
        for (int i = 0; i < [thermostatIds count]; i++) {
            Thermostat *newThermostat = [[Thermostat alloc] init];
            newThermostat.thermostatId = [thermostatIds objectAtIndex:i];
            [returnArray addObject:newThermostat];
        }
    }
    
    return returnArray;
}

/**
 * Create new thermostats for the given structure
 * @param The structure you want to create thermostats for
 * @return The list of thermostats in the structure in an NSArray
 */
- (NSArray *)camerasForStructure:(NSDictionary *)structure
{
    NSString *structureId = [[structure allKeys] objectAtIndex:0];
    NSArray *cameraIds = [[structure objectForKey:structureId] objectForKey:@"cameras"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    if (!cameraIds || [cameraIds count] == 0) {
        return nil;
    } else {
        for (int i = 0; i < [cameraIds count]; i++) {
            Camera *newCamera = [[Camera alloc] init];
            newCamera.cameraId = [cameraIds objectAtIndex:i];
            [returnArray addObject:newCamera];
        }
    }
    
    return returnArray;
}

@end
