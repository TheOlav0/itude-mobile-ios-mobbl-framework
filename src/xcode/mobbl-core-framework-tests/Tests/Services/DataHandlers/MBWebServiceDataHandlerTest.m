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

static NSString * const TestArgumentsReformattingEditPath = @"WillBeReformatted[0]/@text()";
static NSString * const TestArgumentsReformattingReplacementValue = @"This field is reformatted";

static NSString * const TestConfigFileName = @"MBWebServiceDataHandlerTest_config.xml";
static NSString * const TestEndpointsFileName = @"MBWebServiceDataHandlerTest_endpoints.xml";

@interface MBWebServiceDataHandlerTest : XCTestCase

- (MBHTTPConnectionBuilder)connectionBuilderWithBehavior:(NSArray *)connectionBehavior;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithBehavior:(NSArray *)behavior;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithCacheStorage:(id<MBDocumentCaching>)documentCacheStorage;
- (MBMockWebServiceDataHandler *)mockWebServiceDataHandlerWithHTTPBehavior:(NSArray *)behavior documentCacheStorage:(id<MBDocumentCaching>)documentCacheStorage;

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
    [testArguments setValue:TestArgumentsReformattingEditPath forPath:MBMockWebServiceArgumentsReformattingEditPathPath];
    [testArguments setValue:TestArgumentsReformattingReplacementValue forPath:MBMockWebServiceArgumentsReformattingReplacementValuePath];
    
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
    NSArray * const mockConnectionBehavior = @[
                                               [self httpDataEventWithData:httpData],
                                               [self httpResponseEventWithHeaderFields:@{} httpVersion:@"HTTP/1.1" httpStatusCode:200]
                                               ];
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
    NSArray * const mockConnectionBehavior = @[
                                               [self httpDataEventWithData:httpData],
                                               [self httpResponseEventWithHeaderFields:@{} httpVersion:@"HTTP/1.1" httpStatusCode:200]
                                               ];
    __block NSURLRequest * urlRequest = nil;
    const MBHTTPConnectionBuilder mockConnectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate>delegate) {
        urlRequest = [request retain];
        return [[MBMockHTTPConnection alloc] initWithRequest:request delegate:delegate connectionBehavior:mockConnectionBehavior];
    };
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:nil];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    MBDocument *testArguments = [self testArguments];
    __unused MBDocument *resultIsIrrelevant = [mockWebServiceDataHandler loadFreshDocument:TestDocumentName withArguments:testArguments];
    
    XCTAssertNotNil(urlRequest);
    
    NSDictionary * const effectiveHTTPHeaders = [urlRequest allHTTPHeaderFields];
    NSString * const httpMethod = [urlRequest HTTPMethod];
    NSString * const requestURLString = [[urlRequest URL] absoluteString];
    
    
    NSMutableDictionary * const expectedHTTPHeaders = [[self defaultHTTPHeaders] mutableCopy];
    expectedHTTPHeaders[TestArgumentsHeaderFieldName] = TestArgumentsHeaderFieldValue;
    
    NSString * const expectedURLString = [[NSString alloc] initWithFormat:@"%@?%@=%@", TestEndpointBaseURLString, MBMockWebServiceURLParamName, TestArgumentsURLParamValue];
    
    XCTAssertEqualObjects(requestURLString, expectedURLString);
    XCTAssertEqualObjects(@"POST", httpMethod);
    XCTAssertEqualObjects(effectiveHTTPHeaders, expectedHTTPHeaders);
    
    [expectedHTTPHeaders release];
    [expectedURLString release];
}


- (void)testCorrectResultLoadFreshNoArguments {
    NSData * const httpData = [self testData];
    NSArray * const mockConnectionBehavior = @[
                                               [self httpDataEventWithData:httpData],
                                               [self httpResponseEventWithHeaderFields:@{} httpVersion:@"HTTP/1.1" httpStatusCode:200]
                                               ];
    
    const MBHTTPConnectionBuilder mockConnectionBuilder = [self connectionBuilderWithBehavior:mockConnectionBehavior];
    
    MBMockWebServiceDataHandler * const mockWebServiceDataHandler = [[MBMockWebServiceDataHandler alloc] initWithConnectionBuilder:mockConnectionBuilder documentCacheStorage:nil];
    XCTAssertNotNil(mockWebServiceDataHandler);
    
    [mockConnectionBuilder release];
    
    MBDocument * const retrievedDocument = [mockWebServiceDataHandler loadFreshDocument:TestDocumentName];
    XCTAssertNotNil(retrievedDocument);
    
    MBDocument * const expectedDocument = [self testDocument];
    
    XCTAssertEqualObjects(expectedDocument, retrievedDocument);
}

- (void)testLoadCachedDocumentNoArgumentsCacheHit {
    MBDocument * const expectedDocument = [self testDocument];
    NSLog(@"Hallo");
    
    MBMockDocumentCacheManager * const mockCacheManager = [[MBMockDocumentCacheManager alloc] initWithCacheItems:@{ TestDocumentName: expectedDocument }];
    
    MBMockWebServiceDataHandler * const mockWebServiceHandler = [self mockWebServiceDataHandlerWithCacheStorage:mockCacheManager];
    XCTAssertNotNil(mockWebServiceHandler);
    
    MBDocument * const retrievedDocument = [mockWebServiceHandler loadDocument:TestDocumentName];
    
    XCTAssertEqualObjects(expectedDocument, retrievedDocument);
    
}

@end
