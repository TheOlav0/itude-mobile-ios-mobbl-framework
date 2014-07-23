//
//  MBMockHTTPConnection.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 21/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import "MBMockHTTPConnection.h"

NSString * const MBMockHTTPConnectionEventDataKey = @"MBMockHTTPConnectionEventDataKey";

NSString * const MBMockHTTPConnectionEventResponseHeaderFieldsKey = @"MBMockHTTPConnectionEventResponseHeaderFieldsKey";
NSString * const MBMockHTTPConnectionEventResponseStatusCodeKey = @"MBMockHTTPConnectionEventResponseStatusCodeKey";
NSString * const MBMockHTTPConnectionEventResponseHTTPVersionKey = @"MBMockHTTPConnectionEventResponseHTTPVersionKey";

NSString * const MBMockHTTPConnectionEventFailureMessageKey = @"MBMockHTTPConnectionEventFailureMessageKey";

@implementation MBMockHTTPConnectionEvent

- (id)initWithType:(MBMockHTTPConnectionEventType)type userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        _type = type;
        _userInfo = [userInfo retain];
    }
    return self;
}

- (void)dealloc {
    [_userInfo release];
    [super dealloc];
}

@end

@interface MBMockHTTPConnection()

@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSArray *connectionBehavior;
@property (nonatomic) BOOL canceled;

- (void)run;

@end

@implementation MBMockHTTPConnection

@synthesize delegate = _delegate;
@synthesize connectionBehavior = _connectionBehavior;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<MBHTTPConnectionDelegate>)delegate connectionBehavior:(NSArray *)connectionBehavior
{
    self = [super init];
    if (self) {
        _request = [request retain];
        _delegate = [delegate retain];
        _connectionBehavior = [connectionBehavior retain];
        
        [self run];
        
    }
    return self;
}

- (NSURLRequest *)currentRequest {
    return self.request;
}

- (NSURLRequest *)originalRequest {
    return self.request;
}

- (void)cancel {
    self.canceled = YES;
}

- (void)run {
    for (MBMockHTTPConnectionEvent *event in self.connectionBehavior) {
        if (self.canceled) {
            break;
        }
        switch (event.type) {
            case MBMockHTTPConnectionEventTypeResponse: {
                NSURL *url = [self.request URL];
                NSUInteger httpStatusCode = [event.userInfo[MBMockHTTPConnectionEventResponseStatusCodeKey] integerValue];
                NSString *httpVersion = event.userInfo[MBMockHTTPConnectionEventResponseHTTPVersionKey];
                NSDictionary *httpHeaderFields = event.userInfo[MBMockHTTPConnectionEventResponseHeaderFieldsKey];
                NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:httpStatusCode HTTPVersion:httpVersion headerFields:httpHeaderFields];
                [self.delegate connection:self didReceiveResponse:httpResponse];
                [httpResponse release];
                
                break;
                
            }
                
            case MBMockHTTPConnectionEventTypeData: {
                NSData *data = event.userInfo[MBMockHTTPConnectionEventDataKey];
                [self.delegate connection:self didReceiveData:data];
                
                break;
            }
                
            case MBMockHTTPConnectionEventTypeFinish: {
                [self.delegate connectionDidFinishLoading:self];
                
                break;
            }
                
            case MBMockHTTPConnectionEventTypeFailure: {
                NSError *error = [[NSError alloc] initWithDomain:event.userInfo[MBMockHTTPConnectionEventFailureMessageKey]
                                                            code:-1
                                                        userInfo:nil];
                [self.delegate connection:self didFailWithError:error];
                [error release];
                
                break;
            }
        }
    }
    
}

- (void)dealloc {
    [_request release];
    [_delegate release];
    [_connectionBehavior release];
    [super dealloc];
}

@end
