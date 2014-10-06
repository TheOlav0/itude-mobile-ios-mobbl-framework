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
//  MBMockWebServiceDataHandler.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 18/07/14.

#import "MBMockWebServiceDataHandler.h"

NSString * const MBMockWebServiceArgumentsURLParamPath = @"UrlParam[0]/@text()";
NSString * const MBMockWebServiceArgumentsHeaderFieldNamePath = @"HTTPHeaderFieldName[0]/@text()";
NSString * const MBMockWebServiceArgumentsHeaderFieldValuePath = @"HTTPHeaderFieldValue[0]/@text()";
NSString * const MBMockWebServiceArgumentsBodyPath = @"HTTPBody[0]/@text()";
NSString * const MBMockWebServiceArgumentsReformattingEditPathPath = @"ReformattingEditPath[0]/@text()";
NSString * const MBMockWebServiceArgumentsReformattingFormatPath = @"ReformattingFormat[0]/@text()";

NSString * const MBMockWebServiceURLParamName = @"urlParam";

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
    MBDocument * const reformattedDocument = [doc copy];
    
    if (reformattedDocument) {
        NSString * const editPath = [doc valueForPath:MBMockWebServiceArgumentsReformattingEditPathPath];
        NSString * const formattingFormat = [doc valueForPath:MBMockWebServiceArgumentsReformattingFormatPath];
        
        NSString * const originalValue = [doc valueForPath:editPath];
        NSString * const newValue = [[NSString alloc] initWithFormat:formattingFormat, originalValue];
        
        [reformattedDocument setValue:newValue forPath:editPath];
        
        [newValue release];
    }
    
    return reformattedDocument;
}

@end
