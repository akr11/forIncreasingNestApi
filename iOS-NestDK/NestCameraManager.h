//
//  NestCameraManager.h
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

#import "Camera.h"
#import "Constants.h"

@protocol NestCameraManagerDelegate <NSObject>

- (void)cameraValuesChanged:(Camera *)camera;
- (void)errorDisplay:(NSError *)error;

@end

@interface NestCameraManager : NSObject

@property (nonatomic, strong) id <NestCameraManagerDelegate>delegate;
@property (nonatomic, strong) NSString *redirectURL;

- (void)setupPollTimer:(Camera *)camera;
- (void)invalidatePollTimer;
- (void)getStateForCamera:(Camera *)camera;
- (void)saveChangesForCamera:(Camera *)camera forEndpoint:(NestEndpoint)endpoint;

@end
