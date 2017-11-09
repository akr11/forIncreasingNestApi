//
//  Camera.h
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

@interface Camera : NSObject
@property (nonatomic, strong) NSString *cameraId;
@property (nonatomic, strong) NSString *nameLong;
@property (nonatomic) BOOL isAudioInputEnabled;
@property (nonatomic) BOOL isOnline;
@property (nonatomic) BOOL isPublicShareEnabled;
@property (nonatomic) BOOL isStreaming;
@property (nonatomic) BOOL isVideoHistoryEnabled;
@property (nonatomic) BOOL lastEventHasMotion;
@property (nonatomic) BOOL lastEventHasPerson;
@property (nonatomic) BOOL lastEventHasSound;
@property (nonatomic) BOOL streamingTimerActive;
@property (nonatomic, strong) NSDate  *lastEventStartTime;
@property (nonatomic, strong) NSDate  *lastEventEndTime;
@property (nonatomic, strong) NSDate  *lastEventUrlsExpiredTime;
@end
