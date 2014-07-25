//
//  MBMockWebServiceDataHandler.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 18/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import "MBMockWebServiceDataHandler.h"

NSString * const MBMockWebServiceArgumentsURLParamPath = @"UrlParam[0]/@text()";
NSString * const MBMockWebServiceArgumentsHeaderFieldNamePath = @"HTTPHeaderFieldName[0]/@text()";
NSString * const MBMockWebServiceArgumentsHeaderFieldValuePath = @"HTTPHeaderFieldValue[0]/@text()";
NSString * const MBMockWebServiceArgumentsBodyPath = @"HTTPBody[0]/@text()";
NSString * const MBMockWebServiceArgumentsReformattingEditPathPath = @"ReformattingEditPath[0]/@text()";
NSString * const MBMockWebServiceArgumentsReformattingReplacementValuePath = @"ReformattingReplacementValue[0]/@text()";

NSString * const MBMockWebServiceURLParamName = @"urlParam";

//NSString * const AttributePath = @"@unit-test";
//NSString * const AttributeValue = @"Add attribute test";
//NSString * const ChecksumPath = @"@checksum";
//NSString * const ChecksumValue = @"unit-test-checksum-value";

@implementation MBMockWebServiceDataHandler

- (NSString *)url:(NSString *)url WithArguments:(MBDocument *)args {
    NSString *processedUrl = [super url:url WithArguments:args];
    
    NSString *urlParam = [args valueForPath:MBMockWebServiceArgumentsURLParamPath];
    
    processedUrl = [processedUrl stringByAppendingFormat:@"?%@=%@", MBMockWebServiceURLParamName, urlParam];
    
    return processedUrl;
}

- (void)setHTTPHeaders:(NSMutableURLRequest *)request withArguments:(MBDocument *)args {
    [super setHTTPHeaders:request withArguments:args];

    NSString * const headerFieldName = [args valueForPath:MBMockWebServiceArgumentsHeaderFieldNamePath];
    NSString * const headerFieldValue = [args valueForPath:MBMockWebServiceArgumentsHeaderFieldValuePath];

    [request setValue:headerFieldValue forHTTPHeaderField:headerFieldName];
}

- (void)setHTTPRequestBody:(NSMutableURLRequest *)request withArguments:(MBDocument *)args {
    [super setHTTPRequestBody:request withArguments:args];
    
    NSString *bodyString = [args valueForPath:MBMockWebServiceArgumentsBodyPath];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:bodyData];
}

- (MBDocument *)reformatRequestArgumentsForServer:(MBDocument *)doc {
    MBDocument *reformattedDocument = [doc copy];
    NSString *editPath = [doc valueForPath:MBMockWebServiceArgumentsReformattingEditPathPath];
    NSString *replacementValue = [doc valueForPath:MBMockWebServiceArgumentsReformattingReplacementValuePath];
    
    [reformattedDocument setValue:replacementValue forPath:editPath];
    
    return reformattedDocument;
}

//- (void)addAttributesToRequestArguments:(MBDocument *)doc {
//    [doc setValue:AttributeValue forPath:AttributePath];
//}

//- (void)addChecksumToRequestArguments:(MBElement *)element {
//    [element setValue:ChecksumValue forAttribute:ChecksumPath];
//}

@end
