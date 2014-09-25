//
//  MBHTTPConnectionImpl.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 16/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

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
        
        _delegate = [delegate retain];
        
        [self startWithRequest:request];
    }
    
    return self;
}

- (void)dealloc {
    [_delegate release];
    [_connection release];
    
    [super dealloc];
}

#pragma mark - Private methods

- (void)startWithRequest:(NSURLRequest *)request {
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.currentRequest delegate:self];
    
    self.connection = connection;
    
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
    [self.delegate connection:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.delegate connection:self didReceiveData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.delegate connection:self didReceiveResponse:response];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate connectionDidFinishLoading:self];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return [self.delegate connection:self willCacheResponse:cachedResponse];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [self.delegate connection:self canAuthenticateAgainstProtectionSpace:protectionSpace];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.delegate connection:self didReceiveAuthenticationChallenge:challenge];
}

@end
