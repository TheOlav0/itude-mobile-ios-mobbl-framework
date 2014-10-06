/*
 * (C) Copyright Itude Mobile B.V., The Netherlands.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  MBMockHTTPConnection.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 21/07/14.

#import "MBHTTPConnection.h"

extern NSString * const MBMockHTTPConnectionEventDataKey;

extern NSString * const MBMockHTTPConnectionEventResponseHeaderFieldsKey;
extern NSString * const MBMockHTTPConnectionEventResponseStatusCodeKey;
extern NSString * const MBMockHTTPConnectionEventResponseHTTPVersionKey;

extern NSString * const MBMockHTTPConnectionEventFailureMessageKey;

typedef enum {
    MBMockHTTPConnectionEventTypeResponse,
    MBMockHTTPConnectionEventTypeData,
    MBMockHTTPConnectionEventTypeFinish,
    MBMockHTTPConnectionEventTypeFailure,
} MBMockHTTPConnectionEventType;

@interface MBMockHTTPConnectionEvent : NSObject

@property (nonatomic) MBMockHTTPConnectionEventType type;
@property (nonatomic, retain) NSDictionary *userInfo;

- (id)initWithType:(MBMockHTTPConnectionEventType)type userInfo:(id)userInfo;

@end

typedef MBMockHTTPConnectionEvent *(^MBMockHTTPConnectionBehavior)(void);

@interface MBMockHTTPConnection : NSObject <MBHTTPConnection>

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<MBHTTPConnectionDelegate>)delegate connectionBehavior:(NSArray *)connectionBehavior;

@end
