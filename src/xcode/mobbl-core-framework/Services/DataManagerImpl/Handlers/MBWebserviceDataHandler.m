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

#import "MBWebserviceDataHandler.h"
#import "MBMetadataService.h"
#import "DataUtilites.h"
#import "MBCaching.h"
#import "MBCacheManager.h"
#import "MBMacros.h"
#import "MBLocalizationService.h"
#import "MBServerException.h"
#import "Reachability.h"
#import "MBApplicationFactory.h"
#import "MBDocumentFactory.h"
#import "MBResourceService.h"

#import "MBHTTPConnection.h"
#import "MBHTTPConnectionImpl.h"

@interface MBWebserviceDataHandler()

@property (nonatomic, readonly) id<MBDocumentCaching> documentCacheStorage;

-(NSString*) convertDataToString:(NSData*) data;
-(MBHTTPConnectionBuilder)defaultConnectionBuilder;
-(MBWebservicesConfiguration *)defaultConfiguration;
-(id<MBDocumentCaching>)defaultDocumentCacheStorage;

@end

@implementation MBWebserviceDataHandler

- (id) init {
	return [self initWithConfiguration:[self defaultConfiguration] connectionBuilder:[self defaultConnectionBuilder] documentCacheStorage:[self defaultDocumentCacheStorage]];
}

- (id) initWithConfiguration:(MBWebservicesConfiguration *)configuration {
    return [self initWithConfiguration:configuration connectionBuilder:[self defaultConnectionBuilder] documentCacheStorage:[self defaultDocumentCacheStorage]];
}

- (id)initWithConnectionBuilder:(MBHTTPConnectionBuilder)connectionBuilder documentCacheStorage:(id<MBDocumentCaching>)documentCacheStorage {
    return [self initWithConfiguration:[self defaultConfiguration] connectionBuilder:connectionBuilder documentCacheStorage:documentCacheStorage];
}

- (id) initWithConfiguration:(MBWebservicesConfiguration *)configuration connectionBuilder:(MBHTTPConnectionBuilder)connectionBuilder documentCacheStorage:(id<MBDocumentCaching>)documentCacheStorage {
    self = [super init];
    if (self) {
        BOOL anyNilArguments = (!configuration || !connectionBuilder);
        if (anyNilArguments) {
            [self release];
            return nil;
        }
        
        _connectionBuilder = [connectionBuilder retain];
        _webServiceConfiguration = [configuration retain];
        _documentCacheStorage = [documentCacheStorage retain];
    }
    return self;
}

- (MBWebservicesConfiguration *)defaultConfiguration {
    MBWebservicesConfigurationParser *parser = [[MBWebservicesConfigurationParser alloc] init];
    NSString *documentName = [[MBMetadataService sharedInstance] endpointsName];
    NSData *data = [[MBResourceService sharedInstance].fileManager dataWithContentsOfMainBundle: documentName];
    
    MBWebservicesConfiguration *webServiceConfiguration = [[parser parseData:data ofDocument: documentName] retain];
    
    [parser release];
    
    return webServiceConfiguration;
}

- (MBHTTPConnectionBuilder)defaultConnectionBuilder {
    MBHTTPConnectionBuilder connectionBuilder = ^id<MBHTTPConnection>(NSURLRequest *request, id<MBHTTPConnectionDelegate> delegate) {
        return [[[MBHTTPConnectionImpl alloc] initWithRequest:request delegate:delegate] autorelease];
    };
    
    return [connectionBuilder copy];
}

- (id<MBDocumentCaching>)defaultDocumentCacheStorage {
    return [MBCacheManager sharedInstance];
}

- (MBEndPointDefinition *) getEndPointForDocument:(NSString*)name {
	return [_webServiceConfiguration getEndPointForDocumentName:name];
}

- (MBDocument *) loadDocument:(NSString *)documentName {
	MBDocument *result = [self loadDocument:documentName withArguments:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkActivity" object: nil];
	return result;
}

-(MBDocument *) loadDocument:(NSString *)documentName withArguments:(MBDocument *)doc{
	BOOL cacheable = FALSE;
    // Look for any cached result. If there; return it
	MBEndPointDefinition *endPoint = [self getEndPointForDocument:documentName];
	cacheable = [endPoint cacheable];
	if(cacheable) {
        NSString *uniqueId = nil;
        if(doc){
            uniqueId = [doc uniqueId];
        }
        else{
            uniqueId = documentName;
        }
		MBDocument *result = [self.documentCacheStorage documentForKey:uniqueId];
		if(result != nil) return result;
	}
	return [self loadFreshDocument:documentName withArguments:doc];
}

-(MBDocument *) loadFreshDocument:(NSString *)documentName{
	MBDocument *result = [self loadFreshDocument:documentName withArguments:nil];
	return result;
}

-(MBDocument *) loadFreshDocument:(NSString *)documentName withArguments:(MBDocument *)doc{
    MBDocument *reformattedArgs = [self reformatRequestArgumentsForServer:doc];
    MBDocument *result = nil;
    NSString *uniqueId = nil;
    if(doc){
        uniqueId = [doc uniqueId];
    }
    else{
        uniqueId = documentName;
    }
    @try {
        result = [self doLoadFreshDocument:documentName withArguments:reformattedArgs];
        BOOL cacheable = FALSE;
        MBEndPointDefinition *endPoint = [self getEndPointForDocument:documentName];
        cacheable = [endPoint cacheable];
        if(cacheable) {
            [self.documentCacheStorage setDocument:result forKey:uniqueId timeToLive:endPoint.ttl];
        }
    }
    @catch (NSException *exception) {
        if (self->_webServiceConfiguration.eraseDocumentFromCacheOnError)
            [self.documentCacheStorage expireDocumentForKey:uniqueId];
        @throw exception;
    }
    @finally {
        
    }
	return result;
}

- (MBDocument *) doLoadFreshDocument:(NSString *)documentName withArguments:(MBDocument *)args {
    MBDocument *responseDoc = nil;
	MBEndPointDefinition *endPoint = [self getEndPointForDocument:documentName];
	DLog(@"loadDocument %@ from %@", documentName, endPoint.endPointUri);
	
	if (endPoint != nil)
	{
		NSString *dataString = nil;
        NSData *data = nil;
        @try{
            NSString *urlString = [self url:endPoint.endPointUri WithArguments:args];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:endPoint.timeout];
            [self setHTTPHeaders:request withArguments:args];
            [self setHTTPRequestBody:request withArguments:args];
            data = [self dataFromRequest:request withDocumentName:(NSString*) documentName andEndpoint:endPoint];
            dataString = [self convertDataToString:data];
            [self checkResultListenerMatchesInEndpoint:endPoint withArguments:args withResponse:dataString];
            responseDoc = [self documentWithData:data andDocumentName:documentName];
        } @catch (NSException * e) {
            if (args) {
                DLog(@"%@",[[args valueForPath:@"/*[0]"] asXmlWithLevel:0]);
            }
            if (dataString) {
                DLog(@"%@",dataString);
            }
            @throw e;
        }
    }
    else {
        WLog(@"No endpoint defined for document name '%@'", documentName);
        return nil;
    }
    return responseDoc;
}


-(NSString *)url:(NSString *)url WithArguments:(MBDocument*)args{
    return url;
}

-(void) setHTTPHeaders:(NSMutableURLRequest *)request withArguments:(MBDocument*) args{
    [request setHTTPMethod:@"POST"];
    // Content-Type must be set because otherwise Tomcat 6 gives an error
    // MIME type application/x-www-form-encoded is the default
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    
}
-(void) setHTTPRequestBody:(NSMutableURLRequest *)request withArguments:(MBDocument*) args{
    NSString *body = [[args valueForPath:@"/*[0]"] asXmlWithLevel:0];
    if(body != nil) [request setHTTPBody: [body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(NSData *) dataFromRequest:(NSURLRequest *)request withDocumentName:(NSString*) documentName andEndpoint:(MBEndPointDefinition*)endPoint{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    MBHTTPConnectionDelegateImpl *delegate = [MBHTTPConnectionDelegateImpl new];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:endPoint.timeout target:(delegate) selector:@selector(cancel) userInfo:nil repeats:NO];
    @try {
        delegate.err = nil;
        delegate.response = nil;
        delegate.finished = NO;
        delegate.data = [[NSMutableData new] autorelease];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];

        id<MBHTTPConnection> connection = self.connectionBuilder(request, delegate);
        if ((delegate.connection = connection)){
            while (!delegate.finished) {
                [self checkForConnectionErrorsInDelegate:delegate withDocumentName:documentName andEndPoint:endPoint];
                // Wait for async http request to finish, but make sure delegate methods are called, since this is executed in an NSOperation
                [[NSRunLoop currentRunLoop] runMode:connection.runMode beforeDate:[NSDate distantFuture]];
            }
            [timer invalidate];
            if (delegate.err != nil) {
				WLog(@"An error (%@) occured while accessing endpoint '%@'", delegate.err, endPoint.endPointUri);
				@throw [MBServerException exceptionWithName:MBLocalizedString(@"Network error") reason:[delegate.err localizedDescription] userInfo:[delegate.err userInfo]];
			}
            if (!delegate.data || delegate.data.length==0) {
				WLog(@"No data returned in response while accessing endpoint '%@'. response was: %@", endPoint.endPointUri, delegate.response.description);
				@throw [MBServerException exceptionWithName:MBLocalizedString(@"Network error") reason:[delegate.response debugDescription] userInfo:[delegate.err userInfo]];
			}
        }
        return delegate.data;
    }
    @catch (NSException * e) {
        @throw e;
    }
    @finally {
        [delegate release];
        [timer invalidate];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

-(void)checkForConnectionErrorsInDelegate:(MBHTTPConnectionDelegateImpl *)delegate withDocumentName:(NSString*)documentName andEndPoint:(MBEndPointDefinition *)endPoint{
    NSString *endPointUri = endPoint.endPointUri;
    NSURL *url = nil;
    NSString *hostName = nil;
    Reachability *reachability = nil;
    NetworkStatus networkStatus = NotReachable;
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable){
        // Big problem, throw Exception
        [delegate.connection cancel];
        @throw [MBServerException exceptionWithName:MBLocalizedString(@"Network error") reason:MBLocalizedString(@"No internet connection") userInfo:nil];
    }
    
    
    // Because the application crashed here all these seperate steps are added to pinpoint the excact location of the crash.
    
    if (endPointUri) {
        @try {
            url = [NSURL URLWithString:endPointUri];
        }
        @catch (NSException * e) {
            WLog(@"WARNING! MBWebserviceServiceDataHandler:Prevented a crash while creating an NSURL from the endpointUri while loading document %@. Exception: %@",documentName,e);
        }
    }else {
        WLog(@"WARNING! MBWebserviceServiceDataHandler:The endpointUri (%@) could not be retrieved while loading document %@.",endPointUri,documentName);
    }
    
    if (url) {
        hostName = [url host];
    }else {
        WLog(@"WARNING! MBWebserviceServiceDataHandler:The url (%@) could not be retrieved while loading document %@.",url,documentName);
    }
    
    if (hostName && ([hostName length]>0)) {
        reachability = [Reachability reachabilityWithHostName:hostName];
    } else {
        WLog(@"WARNING! MBWebserviceServiceDataHandler:The hostName (%@) could not be retrieved while loading document %@.",hostName, documentName);
    }
    
    if (reachability) {
        networkStatus = [reachability currentReachabilityStatus];
    } else {
        WLog(@"WARNING! MBWebserviceServiceDataHandler:The reachability (%@) could not be retrieved while loading document %@.",reachability,documentName);
    }
    
    if (networkStatus == NotReachable) {
        // Big problem, throw Exception
        [delegate.connection cancel];
        @throw [MBServerException exceptionWithName:MBLocalizedString(@"Network error") reason:MBLocalizedString(@"Server unreachable") userInfo:nil];
    }
    
}

-(NSString*) convertDataToString:(NSData*) data{
    NSString *string = nil;
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!string){
        string = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    }
    if(!string){
        string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    [string autorelease];
    return string;
}


-(BOOL) checkResultListenerMatchesInEndpoint:(MBEndPointDefinition *)endPoint withArguments:(MBDocument*)args withResponse:(NSString*)dataString{
    for(MBResultListenerDefinition *lsnr in [endPoint resultListeners]) {
        if([lsnr matches:dataString]) {
            id<MBResultListener> rl = [[MBApplicationFactory sharedInstance] createResultListener:lsnr.name];
            [rl handleResult:dataString requestDocument:args definition: lsnr];
            return YES;
        }
    }
    return NO;
}

-(MBDocument *) documentWithData:(NSData *)data andDocumentName:(NSString *)documentName{
    return [[MBDocumentFactory sharedInstance] documentWithData:data withType:PARSER_XML andDefinition:[[MBMetadataService sharedInstance] definitionForDocumentName:documentName]];
}


- (void) storeDocument:(MBDocument *)document {
}


-(MBDocument *) reformatRequestArgumentsForServer:(MBDocument * )doc{
    return doc;
}

- (void) dealloc {
	[_webServiceConfiguration release];
    [_connectionBuilder release];
    [_documentCacheStorage release];
	[super dealloc];
}


@end


// uncomment to allow self signed SSL certificates
// #define ALLOW_SELFSIGNED_SSL_CERTS 1

@implementation MBHTTPConnectionDelegateImpl

-(void) dealloc{
	[_data release];
    [_err release];
	[_response release];
	[_connection release];
	[super dealloc];
}

- (void)connection:(id<MBHTTPConnection>)connection didFailWithError:(NSError *)error {
	_finished = YES;
	self.err = error;
	
}

- (void)connection:(id<MBHTTPConnection>)connection didReceiveData:(NSData *)data {
	[self.data appendData:data];
}


- (void)connection:(id<MBHTTPConnection>)connection didReceiveResponse:(NSURLResponse *)response {
	[self.data setLength:0];
	self.response = response;
}

- (void)connectionDidFinishLoading:(id<MBHTTPConnection>)connection {
	self.finished = YES;
}

- (void) cancel{
    [self.connection cancel];
    self.finished = YES;
}

- (NSCachedURLResponse *)connection:(id<MBHTTPConnection>)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
	// never cache the response of the urlConnection here.
	return nil;
}

#ifdef ALLOW_SELFSIGNED_SSL_CERTS

- (BOOL)connection:(id<MBHTTPConnection>)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(id<MBHTTPConnection>)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#endif

@end
