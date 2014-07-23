//
//  MBMockWebServiceDataHandler.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 18/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import "MBMockWebServiceDataHandler.h"

static NSString * const URLParamPath = @"UrlParam[0]/@text()";
static NSString * const HeaderFieldName = @"X-Unit-Test";
static NSString * const HeaderFieldNamePath = @"HTTPHeader[0]/@text()";
static NSString * const BodyPath = @"HTTPBody[0]/@text()";
static NSString * const ReformattingPath = @"Reformatting[0]/@text()";
static NSString * const ReformattingValue = @"Reformatting arguments test";
//static NSString * const AttributePath = @"@unit-test";
//static NSString * const AttributeValue = @"Add attribute test";
//static NSString * const ChecksumPath = @"@checksum";
//static NSString * const ChecksumValue = @"unit-test-checksum-value";

@implementation MBMockWebServiceDataHandler

- (NSString *)url:(NSString *)url WithArguments:(MBDocument *)args {
    NSString *processedUrl = [super url:url WithArguments:args];
    
    NSString *urlParam = [args valueForPath:URLParamPath];
    
    processedUrl = [processedUrl stringByAppendingFormat:@"?urlParam=%@", urlParam];
    
    return processedUrl;
}

- (void)setHTTPHeaders:(NSMutableURLRequest *)request withArguments:(MBDocument *)args {
    [super setHTTPHeaders:request withArguments:args];
    
    NSString *headerValue = [args valueForPath:HeaderFieldNamePath];
    
    [request setValue:headerValue forHTTPHeaderField:HeaderFieldName];
}

- (void)setHTTPRequestBody:(NSMutableURLRequest *)request withArguments:(MBDocument *)args {
    [super setHTTPRequestBody:request withArguments:args];
    
    NSString *bodyString = [args valueForPath:BodyPath];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:bodyData];
}

- (MBDocument *)reformatRequestArgumentsForServer:(MBDocument *)doc {
    MBDocument *reformattedDocument = [doc copy];
    [reformattedDocument setValue:ReformattingValue forPath:ReformattingPath];
    
    return reformattedDocument;
}

//- (void)addAttributesToRequestArguments:(MBDocument *)doc {
//    [doc setValue:AttributeValue forPath:AttributePath];
//}

//- (void)addChecksumToRequestArguments:(MBElement *)element {
//    [element setValue:ChecksumValue forAttribute:ChecksumPath];
//}

@end
