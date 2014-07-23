//
//  MBWebServiceDataHandlerTest.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 17/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MBMetadataService.h"

#import "MBMockHTTPConnection.h"

#import "MBMockWebServiceDataHandler.h"

static NSString * const TestDocumentName = @"WebCallResult";
static NSString * const TestDocumentResultElementName = @"Result";
static NSString * const TestDocumentResultValue = @"1";

@interface MBWebServiceDataHandlerTest : XCTestCase

@property (nonatomic, retain) MBMockWebServiceDataHandler *webServiceDataHandler;

- (MBHTTPConnectionBuilder)connectionBuilderWithBehavior:(NSArray *)connectionBehavior;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithBehavior:(NSArray *)behavior;
- (NSData *)testData;
- (MBMockHTTPConnectionEvent *)httpResponseEventWithHeaderFields:(NSDictionary *)httpHeaders httpVersion:(NSString *)httpVersion httpStatusCode:(NSUInteger)httpStatusCode;
- (MBMockHTTPConnectionEvent *)httpFailureEventWithErrorMessage:(NSString *)message;
- (MBMockHTTPConnectionEvent *)httpDataEventWithData:(NSData *)data;

- (void)testLoadFreshDocumentDataFinish;

@end

@implementation MBWebServiceDataHandlerTest

- (void)setUp
{
    MBMetadataService *metadataService = [MBMetadataService sharedInstance];
    
    [metadataService setConfigName:@"MBWebServiceDataHandler_config.xml"];
    [metadataService setEndpointsName:@"MBWebServiceDataHandler_endpoints.xml"];
}

- (MBMockHTTPConnectionEvent *)httpDataEventWithData:(NSData *)data {
    MBMockHTTPConnectionEvent *event = [[MBMockHTTPConnectionEvent alloc] initWithType:MBMockHTTPConnectionEventTypeData
                                                                              userInfo:@{ MBMockHTTPConnectionEventDataKey: data }];
    
    return [event autorelease];
}

- (MBMockHTTPConnectionEvent *)httpResponseEventWithHeaderFields:(NSDictionary *)httpHeaders httpVersion:(NSString *)httpVersion httpStatusCode:(NSUInteger)httpStatusCode {
    MBMockHTTPConnectionEvent *event = [[MBMockHTTPConnectionEvent alloc] initWithType:MBMockHTTPConnectionEventTypeFinish
                                                                              userInfo: @{
                                                                                          MBMockHTTPConnectionEventResponseHeaderFieldsKey: httpHeaders,
                                                                                          MBMockHTTPConnectionEventResponseHTTPVersionKey: httpVersion,
                                                                                          MBMockHTTPConnectionEventResponseStatusCodeKey: @(httpStatusCode)
                                                                                          }];
    
    return [event autorelease];
}

- (MBMockHTTPConnectionEvent *)httpFailureEventWithErrorMessage:(NSString *)message {
    MBMockHTTPConnectionEvent *event = [[MBMockHTTPConnectionEvent alloc] initWithType:MBMockHTTPConnectionEventTypeFailure
                                                                              userInfo:@{ MBMockHTTPConnectionEventFailureMessageKey: message }];
    
    return [event autorelease];
}

- (MBHTTPConnectionBuilder)connectionBuilderWithBehavior:(NSArray *)connectionBehavior {
    [connectionBehavior retain];
    const MBHTTPConnectionBuilder connectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate> delegate)
    {
        id<MBHTTPConnection> httpConnection = [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:connectionBehavior];
        [connectionBehavior release];
        
        return httpConnection;
    };
    
    return [[connectionBuilder copy] autorelease];
}

- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithBehavior:(NSArray *)behavior {
    const MBHTTPConnectionBuilder mockConnectionBuilder = [self connectionBuilderWithBehavior:behavior];
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder];
    
    return mockWebServiceDataHandler;
}

- (NSData *)testData {
    NSString *testDataString = [[NSString alloc] initWithFormat:
                                @"<%@>\n"
                                @"  <%@>%@</%@>\n"
                                @"</%@>",
                                TestDocumentName,
                                TestDocumentResultElementName,
                                TestDocumentResultValue,
                                TestDocumentResultElementName,
                                TestDocumentName
                                ];
    NSData *testData = [testDataString dataUsingEncoding:NSUTF8StringEncoding];
    [testDataString release];
    
    return testData;
}

- (void)testLoadFreshDocumentDataFinish {
    NSData * const httpData = [self testData];
    NSDictionary * const httpHeaders = @{ @"Content-Length": @"42" };
    NSArray * const mockConnectionBehavior = @[
                                               [self httpDataEventWithData:httpData],
                                               [self httpResponseEventWithHeaderFields:httpHeaders httpVersion:@"HTTP/1.1" httpStatusCode:200]
                                               ];
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [self mockWebServiceDataHandlerWithBehavior:mockConnectionBehavior];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    MBDocument * const document = [mockWebServiceDataHandler loadFreshDocument:TestDocumentName];
    XCTAssertNotNil(document);

    NSDictionary * const elementDictionary = [document elements];
    
    NSArray * const uniqueElementNames = [elementDictionary allKeys];
    
    XCTAssert([uniqueElementNames count] == 1);
    XCTAssertEqualObjects(uniqueElementNames[0], TestDocumentResultElementName);
    MBElement *resultElement = [document valueForPath:TestDocumentResultElementName][0];
    NSString *resultElementValue = [resultElement valueForAttribute:@"text()"];
    XCTAssertEqual([resultElementValue integerValue], [TestDocumentResultValue integerValue]);
    
    [mockWebServiceDataHandler release];
    [mockConnectionBehavior release];
}

//- (void)testLoadFreshDocument {
//
//}


//- (void)testLoadDocumentWithArguments {
//    
//}
//
//
//- (void)testLoadFreshDocumentWithArguments {
//    
//}

@end
