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
//  MBHTTPConnectionImpl.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 16/07/14.

#import "MBHTTPConnectionImpl.h"

@interface MBHTTPConnectionImpl() <NSURLConnectionDataDelegate>

@property (nonatomic, retain) NSURLConnection *connection;

- (void)startWithRequest:(NSURLRequest *)request;

@end

@implementation MBHTTPConnectionImpl

#pragma mark - Properties

@synthesize delegate = _delegate;

#pragma mark - Object lifecycle

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<MBHTTPConnectionDelegate>)delegate {
    self = [super init];
    if (self) {
        if (!request || !delegate) {
            [self release];
            return nil;
        }
        
        _delegate = delegate;
        
        [self startWithRequest:request];
    }
    
    return self;
}

- (void)dealloc {
    [_connection release];
    
    [super dealloc];
}

#pragma mark - Private methods

- (void)startWithRequest:(NSURLRequest *)request {
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    self.connection = connection;
    
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:self.runLoopMode];
    
    [self.connection start];
    
    [connection release];
}

#pragma mark - Public methods

- (void)cancel {
    [self.connection cancel];
}

- (NSURLRequest *)originalRequest {
    return [self.connection originalRequest];
}

- (NSURLRequest *)currentRequest {
    return [self.connection currentRequest];
}

#pragma mark - Connection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [self.delegate connection:self didFailWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.delegate connection:self didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.delegate connection:self didReceiveResponse:response];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.delegate connectionDidFinishLoading:self];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return [self.delegate connection:self willCacheResponse:cachedResponse];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([self.delegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [self.delegate connection:self canAuthenticateAgainstProtectionSpace:protectionSpace];
    } else {
        return NO;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
        return [self.delegate connection:self didReceiveAuthenticationChallenge:challenge];
    }
}

-(NSString*) runLoopMode {
    return @"MBHTTPConnectionRunMode";
}

@end
