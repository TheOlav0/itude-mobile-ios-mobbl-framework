//
//  MBHTTPConnectionDelegate.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 16/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBHTTPConnection;


@protocol MBHTTPConnectionDelegate <NSObject>

@optional
- (void)connection:(id<MBHTTPConnection>)connection didFailWithError:(NSError *)error;
- (void)connection:(id<MBHTTPConnection>)connection didReceiveData:(NSData *)data;
- (void)connection:(id<MBHTTPConnection>)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(id<MBHTTPConnection>)connection;
- (NSCachedURLResponse *)connection:(id<MBHTTPConnection>)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (BOOL)connection:(id<MBHTTPConnection>)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(id<MBHTTPConnection>)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
