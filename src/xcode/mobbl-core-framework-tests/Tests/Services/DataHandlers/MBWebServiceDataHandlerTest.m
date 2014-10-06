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
//  MBWebServiceDataHandlerTest.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 17/07/14.

#import <XCTest/XCTest.h>
#import "MBMetadataService.h"

#import "MBMockHTTPConnection.h"
#import "MBMockDocumentCacheManager.h"

#import "MBMockWebServiceDataHandler.h"

static NSString * const TestDocumentName = @"WebCallResult";
static NSString * const TestDocumentResultElementName = @"Result";
static NSString * const TestDocumentResultValue = @"1";

static NSString * const TestEndpointBaseURLString = @"http://example.com/resource";

static NSString * const TestArgumentsDocumentName = @"WebCallParameters";
static NSString * const TestArgumentsURLParamValue = @"test_url_param_value";
static NSString * const TestArgumentsHeaderFieldName = @"X-Unit-Test";
static NSString * const TestArgumentsHeaderFieldValue = @"unit-test-value";
static NSString * const TestArgumentsBodyText = @"This is the body.\nIt includes a newline.";

static NSString * const TestArgumentsReformattingFormat = @"Reformatted(%@)";

static NSString * const TestConfigFileName = @"MBWebServiceDataHandlerTest_config.xml";
static NSString * const TestEndpointsFileName = @"MBWebServiceDataHandlerTest_endpoints.xml";

@interface MBWebServiceDataHandlerTest : XCTestCase

- (MBHTTPConnectionBuilder)connectionBuilderWithBehavior:(NSArray *)connectionBehavior;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithBehavior:(NSArray *)behavior;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithCacheStorage:(id<MBDocumentCaching>)documentCacheStorage;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithHTTPBehavior:(NSArray *)behavior documentCacheStorage:(id<MBDocumentCaching>)documentCacheStorage;

- (NSArray *)connectionBehaviorWithData:(NSData *)httpData andFinishWithResponseHeaders:(NSDictionary *)responseHeaders;
- (NSArray *)connectionBuilderWithFailureBehavior;

- (NSData *)testData;
- (MBDocument *)testDocument;
- (NSDictionary *)defaultHTTPHeaders;

- (MBMockHTTPConnectionEvent *)httpResponseEventWithHeaderFields:(NSDictionary *)httpHeaders httpVersion:(NSString *)httpVersion httpStatusCode:(NSUInteger)httpStatusCode;
- (MBMockHTTPConnectionEvent *)httpFailureEventWithErrorMessage:(NSString *)message;
- (MBMockHTTPConnectionEvent *)httpDataEventWithData:(NSData *)data;

- (void)testCorrectHTTPRequestLoadFreshNoArguments;
- (void)testCorrectHTTPRequestLoadFreshWithArguments;

- (void)testCorrectResultLoadFreshNoArguments;
- (void)testCorrectResultLoadFreshWithArguments;

- (void)testFailureHandlingLoadFreshNoArguments;
- (void)testFailureHandlingLoadFreshWithArguments;

- (void)testCacheHitNoArguments;
- (void)testCacheHitWithArguments;

- (void)testCacheMissNoArguments;
- (void)testCacheMissWithArguments;

@end

@implementation MBWebServiceDataHandlerTest

- (void)setUp
{
    MBMetadataService *metadataService = [MBMetadataService sharedInstance];
    
    [metadataService setConfigName:TestConfigFileName];
    [metadataService setEndpointsName:TestEndpointsFileName];
}

- (MBMockHTTPConnectionEvent *)httpDataEventWithData:(NSData *)data {
    MBMockHTTPConnectionEvent * const event = [[MBMockHTTPConnectionEvent alloc] initWithType:MBMockHTTPConnectionEventTypeData
                                                                              userInfo:@{ MBMockHTTPConnectionEventDataKey: data }];
    
    return [event autorelease];
}

- (MBMockHTTPConnectionEvent *)httpResponseEventWithHeaderFields:(NSDictionary *)httpHeaders httpVersion:(NSString *)httpVersion httpStatusCode:(NSUInteger)httpStatusCode {
    MBMockHTTPConnectionEvent * const event = [[MBMockHTTPConnectionEvent alloc] initWithType:MBMockHTTPConnectionEventTypeFinish
                                                                              userInfo: @{
                                                                                          MBMockHTTPConnectionEventResponseHeaderFieldsKey: httpHeaders,
                                                                                          MBMockHTTPConnectionEventResponseHTTPVersionKey: httpVersion,
                                                                                          MBMockHTTPConnectionEventResponseStatusCodeKey: @(httpStatusCode)
                                                                                          }];
    
    return [event autorelease];
}

- (MBMockHTTPConnectionEvent *)httpFailureEventWithErrorMessage:(NSString *)message {
    MBMockHTTPConnectionEvent * const event = [[MBMockHTTPConnectionEvent alloc] initWithType:MBMockHTTPConnectionEventTypeFailure
                                                                              userInfo:@{ MBMockHTTPConnectionEventFailureMessageKey: message }];
    
    return [event autorelease];
}

- (MBHTTPConnectionBuilder)connectionBuilderWithBehavior:(NSArray *)connectionBehavior {
    [connectionBehavior retain];
    const MBHTTPConnectionBuilder connectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate> delegate)
    {
        id<MBHTTPConnection> httpConnection = [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:connectionBehavior];
        [connectionBehavior release];
        
        return [httpConnection autorelease];
    };
    
    return [[connectionBuilder copy] autorelease];
}

- (NSArray *)connectionBehaviorWithData:(NSData *)httpData andFinishWithResponseHeaders:(NSDictionary *)responseHeaders {
    NSArray * const behavior = @[
                                 [self httpDataEventWithData:httpData],
                                 [self httpResponseEventWithHeaderFields:responseHeaders httpVersion:@"HTTP/1.1" httpStatusCode:200]
                                 ];
    
    return behavior;
}

- (NSArray *)connectionBuilderWithFailureBehavior {
    NSArray * const behavior = @[
                                 [self httpFailureEventWithErrorMessage:@"Don't worry, it's just a 'mock' error"]
                                 ];

    return behavior;
}

- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithBehavior:(NSArray *)behavior {
    MBMockDocumentCacheManager * const mockCacheManager = [[MBMockDocumentCacheManager alloc] initWithCacheItems:nil];
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [self mockWebServiceDataHandlerWithHTTPBehavior:behavior documentCacheStorage:mockCacheManager];
    [mockCacheManager release];
    
    return mockWebServiceDataHandler;
}

- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithCacheStorage:(id<MBDocumentCaching>)documentCacheStorage {
    return [self mockWebServiceDataHandlerWithHTTPBehavior:@[] documentCacheStorage:documentCacheStorage];
}

- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithHTTPBehavior:(NSArray *)behavior documentCacheStorage:(id<MBDocumentCaching>)documentCacheStorage {
    const MBHTTPConnectionBuilder mockConnectionBuilder = [self connectionBuilderWithBehavior:behavior];
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:documentCacheStorage];
    
    return mockWebServiceDataHandler;
}

- (NSData *)testData {
    NSString * const testDataString = [[self testDocument] asXmlWithLevel:0];
    NSData * const testData = [testDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    return testData;
}

- (MBDocument *)testDocument {
    MBDocumentDefinition * const documentDefinition = [[MBMetadataService sharedInstance] definitionForDocumentName:TestDocumentName];
    MBDocument * const testDocument = [documentDefinition createDocument];
    
    NSString * const resultValuePath = [[NSString alloc] initWithFormat:@"%@[0]/@text()", TestDocumentResultElementName];
    [testDocument setValue:TestDocumentResultValue forPath:resultValuePath];
    [resultValuePath release];
    
    return testDocument;
}

- (MBDocument *)testArguments {
    MBDocumentDefinition * const documentDefinition = [[MBMetadataService sharedInstance] definitionForDocumentName:TestArgumentsDocumentName];
    MBDocument * const testArguments = [documentDefinition createDocument];

    [testArguments setValue:TestArgumentsURLParamValue forPath:MBMockWebServiceArgumentsURLParamPath];
    [testArguments setValue:TestArgumentsBodyText forPath:MBMockWebServiceArgumentsBodyPath];
    [testArguments setValue:TestArgumentsHeaderFieldName forPath:MBMockWebServiceArgumentsHeaderFieldNamePath];
    [testArguments setValue:TestArgumentsHeaderFieldValue forPath:MBMockWebServiceArgumentsHeaderFieldValuePath];

    [testArguments setValue:MBMockWebServiceArgumentsBodyPath forPath:MBMockWebServiceArgumentsReformattingEditPathPath];
    [testArguments setValue:TestArgumentsReformattingFormat forPath:MBMockWebServiceArgumentsReformattingFormatPath];
    
    return testArguments;
}

- (NSDictionary *)defaultHTTPHeaders {
    return @{
             @"Accept": @"application/xml",
             @"Content-Type": @"text/xml",
             };
}

- (void)testCorrectHTTPRequestLoadFreshNoArguments {
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = [self connectionBehaviorWithData:httpData andFinishWithResponseHeaders:@{}];
    
    __block NSURLRequest * urlRequest = nil;
    const MBHTTPConnectionBuilder mockConnectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate>delegate) {
        urlRequest = [request retain];
        return [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:mockConnectionBehavior];
    };
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:nil];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    __unused MBDocument *resultIsIrrelevant = [mockWebServiceDataHandler loadDocument:TestDocumentName];
    
    XCTAssertNotNil(urlRequest);
    
    NSDictionary * const effectiveHTTPHeaders = [urlRequest allHTTPHeaderFields];
    NSString * const httpMethod = [urlRequest HTTPMethod];
    
    NSDictionary * const expectedHTTPHeaders = [self defaultHTTPHeaders];
    
    XCTAssertEqualObjects(@"POST", httpMethod);
    XCTAssertEqualObjects(effectiveHTTPHeaders, expectedHTTPHeaders);
}

- (void)testCorrectHTTPRequestLoadFreshWithArguments {
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = [self connectionBehaviorWithData:httpData andFinishWithResponseHeaders:@{}];
    __block NSURLRequest * urlRequest = nil;
    const MBHTTPConnectionBuilder mockConnectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate>delegate) {
        urlRequest = [request retain];
        return [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:mockConnectionBehavior];
    };
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:nil];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    __unused MBDocument *resultIsIrrelevant = [mockWebServiceDataHandler loadFreshDocument:TestDocumentName withArguments:[self testArguments]];
    
    XCTAssertNotNil(urlRequest);
    
    NSDictionary * const effectiveHTTPHeaders = [urlRequest allHTTPHeaderFields];
    NSMutableDictionary * const expectedHTTPHeaders = [[self defaultHTTPHeaders] mutableCopy];
    expectedHTTPHeaders[TestArgumentsHeaderFieldName] = TestArgumentsHeaderFieldValue;
    XCTAssertEqualObjects(effectiveHTTPHeaders, expectedHTTPHeaders);

    [expectedHTTPHeaders release];

    NSString * const httpMethod = [urlRequest HTTPMethod];
    XCTAssertEqualObjects(@"POST", httpMethod);
    
    NSString * const requestURLString = [[urlRequest URL] absoluteString];
    NSString * const expectedURLString = [[NSString alloc] initWithFormat:@"%@?%@=%@", TestEndpointBaseURLString, MBMockWebServiceURLParamName, TestArgumentsURLParamValue];
    XCTAssertEqualObjects(requestURLString, expectedURLString);
    
    [expectedURLString release];

    NSString * const bodyString = [[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSStringEncodingConversionAllowLossy];
    NSString * const expectedBodyString = [[NSString alloc] initWithFormat:TestArgumentsReformattingFormat, TestArgumentsBodyText];
    XCTAssertEqualObjects(expectedBodyString, bodyString);

    [bodyString release];
    [expectedBodyString release];
}


- (void)testCorrectResultLoadFreshNoArguments {
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = [self connectionBehaviorWithData:httpData andFinishWithResponseHeaders:@{}];
    
    const MBHTTPConnectionBuilder mockConnectionBuilder = [self connectionBuilderWithBehavior:mockConnectionBehavior];
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:nil];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    MBDocument * const retrievedDocument = [mockWebServiceDataHandler loadFreshDocument:TestDocumentName];
    XCTAssertNotNil(retrievedDocument);
    
    MBDocument * const expectedDocument = [self testDocument];
    
    XCTAssertEqualObjects(expectedDocument, retrievedDocument);
}

- (void)testCorrectResultLoadFreshWithArguments {
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = [self connectionBehaviorWithData:httpData andFinishWithResponseHeaders:@{}];
    
    const MBHTTPConnectionBuilder mockConnectionBuilder = [self connectionBuilderWithBehavior:mockConnectionBehavior];
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:nil];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    MBDocument * const retrievedDocument = [mockWebServiceDataHandler loadFreshDocument:TestDocumentName withArguments:[self testArguments]];
    XCTAssertNotNil(retrievedDocument);
    
    MBDocument * const expectedDocument = [self testDocument];
    
    XCTAssertEqualObjects(expectedDocument, retrievedDocument);
}

- (void)testFailureHandlingLoadFreshNoArguments {
    
}

- (void)testFailureHandlingLoadFreshWithArguments {
    
}

- (void)testCacheHitNoArguments {
    MBDocument * const expectedDocument = [self testDocument];
    
    MBMockDocumentCacheManager * const mockCacheManager = [[MBMockDocumentCacheManager alloc] initWithCacheItems:@{ TestDocumentName: expectedDocument }];
    
    MBMockWebServiceDataHandler * const mockWebServiceHandler = [self mockWebServiceDataHandlerWithCacheStorage:mockCacheManager];
    XCTAssertNotNil(mockWebServiceHandler);
    
    MBDocument * const retrievedDocument = [mockWebServiceHandler loadDocument:TestDocumentName];
    
    XCTAssertEqualObjects(expectedDocument, retrievedDocument);
}

- (void)testCacheHitWithArguments {
    MBDocument * const expectedDocument = [self testDocument];
    
    MBMockDocumentCacheManager * const mockCacheManager = [[MBMockDocumentCacheManager alloc] initWithCacheItems:@{ [[self testArguments] uniqueId]: expectedDocument }];
    
    MBMockWebServiceDataHandler * const mockWebServiceHandler = [self mockWebServiceDataHandlerWithCacheStorage:mockCacheManager];
    XCTAssertNotNil(mockWebServiceHandler);
    
    MBDocument * const retrievedDocument = [mockWebServiceHandler loadDocument:TestDocumentName withArguments:[self testArguments]];
    
    XCTAssertEqualObjects(expectedDocument, retrievedDocument);
}

- (void)testCacheMissNoArguments {
    MBMockDocumentCacheManager * const mockCacheManager = [[MBMockDocumentCacheManager alloc] initWithCacheItems:@{}];
    
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = [self connectionBehaviorWithData:httpData andFinishWithResponseHeaders:@{}];
    
    __block NSURLRequest * urlRequest = nil;
    const MBHTTPConnectionBuilder mockConnectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate>delegate) {
        urlRequest = [request retain];
        return [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:mockConnectionBehavior];
    };
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:mockCacheManager];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    __unused MBDocument *resultIsIrrelevant = [mockWebServiceDataHandler loadDocument:TestDocumentName];
    
    XCTAssertNotNil(urlRequest);
}

- (void)testCacheMissWithArguments {
    MBMockDocumentCacheManager * const mockCacheManager = [[MBMockDocumentCacheManager alloc] initWithCacheItems:@{}];
    
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = [self connectionBehaviorWithData:httpData andFinishWithResponseHeaders:@{}];
    
    __block NSURLRequest * urlRequest = nil;
    const MBHTTPConnectionBuilder mockConnectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate>delegate) {
        urlRequest = [request retain];
        return [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:mockConnectionBehavior];
    };
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:mockCacheManager];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    __unused MBDocument *resultIsIrrelevant = [mockWebServiceDataHandler loadDocument:TestDocumentName withArguments:[self testArguments]];
    
    XCTAssertNotNil(urlRequest);

}


@end
