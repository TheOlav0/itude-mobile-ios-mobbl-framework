//
//  MBMockHTTPConnection.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 21/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

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
