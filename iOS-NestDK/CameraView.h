//
//  CameraView.h
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

#import <UIKit/UIKit.h>
#import "Camera.h"
#import "Constants.h"

@protocol CameraViewDelegate <NSObject>

- (void)cameraInfoChange:(Camera *)camera forEndpoint:(NestEndpoint)endpoint;
- (void)showNextCamera;

@end

@interface CameraView : UIView

@property (nonatomic, strong) NSString *isAudioInputEnabled;
@property (nonatomic, strong) NSString *isOnline;
@property (nonatomic, strong) NSString *isPublicShareEnabled;
@property (nonatomic, strong) NSString *isStreaming;
@property (nonatomic, strong) NSString *isVideoHistoryEnabled;
@property (nonatomic, strong) NSString *lastEventHasMotion;
@property (nonatomic, strong) NSString *lastEventHasPerson;
@property (nonatomic, strong) NSString *lastEventHasSound;
@property (nonatomic, strong) NSString *lastEventStartTime;
@property (nonatomic, strong) NSString *lastEventEndTime;
@property (nonatomic, strong) NSString *lastEventUrlsExpiredTime;
@property (nonatomic) BOOL streamingTimerActive;
@property (nonatomic, strong) NSString *cameraId;
@property (nonatomic, strong) NSString *cameraName;
@property (nonatomic, strong) id <CameraViewDelegate>delegate;

- (void)showLoading;
- (void)hideLoading;

- (void)turnStreaming:(BOOL)on;

- (void)updateWithCamera:(Camera *)camera;

- (void)disableView;
- (void)enableView;

@end
