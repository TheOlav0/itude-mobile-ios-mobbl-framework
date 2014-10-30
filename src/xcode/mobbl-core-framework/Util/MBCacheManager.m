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

#import "MBCacheManager.h"
#import "MBCacheWriter.h"
#import "StringUtilities.h"
#import "MBDocument.h"
#import "MBDocumentDefinition.h"
#import "MBMetadataService.h"
#import "MBXmlDocumentParser.h"
#import "DataUtilites.h"
#import "MBDocumentFactory.h"

static MBCacheManager *_instance = nil;

#define CACHE_REGISTRY_FILE @"cache_registry.plist"
#define CACHE_TTL_FILE      @"cache_ttl.plist"
@implementation MBCacheManager

+(instancetype) sharedInstance {
	@synchronized(self) {
		if(_instance == nil) {
			_instance = [[self alloc] init];
		}
	}
	return _instance;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDirectory = [paths objectAtIndex:0];
        _registryFileName = [[docsDirectory stringByAppendingPathComponent: CACHE_REGISTRY_FILE] retain];
        NSMutableDictionary *combined = [[[NSMutableDictionary alloc] initWithContentsOfFile:_registryFileName] autorelease];
		if(combined == nil) combined = [[NSMutableDictionary new] autorelease];
        
		_registry = [NSMutableDictionary new];
		_documentTypes = [NSMutableDictionary new];
		
		for(NSString *key in [combined allKeys]) {
			NSString *value = [combined objectForKey:key];
			NSArray *split = [value componentsSeparatedByString:@":"];
			
			[_registry setValue: [split objectAtIndex:0] forKey:key];
			if([split count] >1) [_documentTypes setValue: [split objectAtIndex:1] forKey:key];
		}
		
        _operationQueue = [NSOperationQueue new];
        [_operationQueue setMaxConcurrentOperationCount:1];
		_temporaryMemoryCache = [NSMutableDictionary new];
        
        _ttlsFileName = [[docsDirectory stringByAppendingPathComponent: CACHE_TTL_FILE] retain];
        
		NSMutableDictionary *ttlFromFile = [[NSMutableDictionary alloc] initWithContentsOfFile:_ttlsFileName];
        if (ttlFromFile) {
            _ttls = [[NSMutableDictionary alloc] initWithDictionary:ttlFromFile];
        } else {
            _ttls = [NSMutableDictionary new];
        }
        [ttlFromFile release];
    }
    return self;
}

- (void) dealloc
{
    [_registry release];
    [_operationQueue release];
    [_registryFileName release];
    [_temporaryMemoryCache release];
	[_documentTypes release];
	[_ttls release];
    [super dealloc];
}

- (NSData *) dataForKey:(NSString *) key {
    return [self doGetValueForKey:key];
}

- (void) setData:(NSData *) data forKey:(NSString*) key timeToLive:(NSUInteger) ttl {
    [self doSetValue:data forKey:key timeToLive:(int)ttl];
}

- (void) expireDataForKey:(NSString *) key {
    [self doExpireDataForKey:key];
}

- (void) expireDocumentForKey:(NSString *) key {
    [self doExpireDataForKey:key];
}

- (void) expireAllDocuments {
    [self doExpireAllDocuments];
}

- (MBDocument *) documentForKey:(NSString *) key {
    return [self doGetDocumentForKey:key];
}

- (void) setDocument:(MBDocument *) document forKey:(NSString *) key timeToLive:(NSUInteger) ttl {
    
}


-(NSString*) determineAbsPath:(NSString*) fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	return [cacheDirectory stringByAppendingPathComponent: fileName];
}

-(NSData*) doGetValueForKey:(NSString*) key {
    
    NSString *fileName;
    @synchronized(_registry) {
        fileName = [_registry valueForKey: key];
		
		// check ttl
		if(fileName != nil) {
			NSTimeInterval maxAge = [[_ttls valueForKey:key] doubleValue];
			NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
			if(maxAge != 0 && maxAge < now) {
				fileName = nil;
				[_ttls removeObjectForKey: key];
			}
		}
    }
    if(fileName == nil) return nil;

	// First try to get it from the temporary memory cache; a writer could be busy writing the file right now;
	NSData *data = nil;
	@synchronized(_temporaryMemoryCache) {
		data = [_temporaryMemoryCache valueForKey: key];	
	}
	
	if(data == nil) data = [NSData dataWithContentsOfFile: [self determineAbsPath: fileName]];
    return data;
}

-(void) doSetValue:(NSData*) data forKey:(NSString*) key  timeToLive:(int) ttl {
    
    // Put the data in the temporary memory cache; to avoid reading a file a writer is not yet done with:
	@synchronized(_temporaryMemoryCache) {
		[_temporaryMemoryCache setValue:data forKey:key];	
	}
	
    NSString *fileName;
    @synchronized(_registry) {
        fileName = [_registry valueForKey: key];
        if(fileName == nil) {
            int maxKey = 0;
            for(NSString *value in [_registry allValues]) {
                maxKey = MAX(maxKey, [value intValue]);
            }
            maxKey++;
            fileName = [NSString stringWithFormat:@"%i", maxKey];
            [_registry setValue:fileName forKey: key];
        }
		
		// Set maximum age based on ttl and the time of 'now':
		NSTimeInterval maxAge;
		if(ttl == 0) maxAge = 0;
		else maxAge = [NSDate timeIntervalSinceReferenceDate] + ttl;
		NSString *maxAgeString = [NSString stringWithFormat:@"%.0f", maxAge];
		[_ttls setValue:maxAgeString forKey:key];

        MBCacheWriter *writer = [[MBCacheWriter alloc] initWithRegistry:_registry 
													   registryFileName: _registryFileName 
														  documentTypes: _documentTypes
																   ttls: _ttls
														   ttlsFileName: _ttlsFileName 
															   fileName: [self determineAbsPath: fileName] 
																   data: data
												   temporaryMemoryCache: _temporaryMemoryCache
																	key: key];
        [_operationQueue addOperation: writer];
        [writer release];
    }
}

-(MBDocument*) doGetDocumentForKey:(NSString*) key {
	NSData *zipped = [self doGetValueForKey: key];
	if(zipped == nil) return nil;
	
	NSData *data = [zipped zlibInflate];
	
	NSString *documentName = [_documentTypes valueForKey:key];
	MBDocumentDefinition *def = [[MBMetadataService sharedInstance] definitionForDocumentName:documentName];
    return [[MBDocumentFactory sharedInstance] documentWithData: data withType:PARSER_XML andDefinition:def];
}

-(void) doSetDocument:(MBDocument*) document forKey:(NSString*) key timeToLive:(int) ttl {
	NSString *docType = [document documentName];
	[_documentTypes setValue:docType forKey:key];
	NSData *data = [[document asXmlWithLevel:0] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *zipped = [data zlibDeflate];
	[self doSetValue:zipped forKey:key timeToLive:ttl];
}

-(void) flushRegistry {
	// Write the registry stuff in the background
	MBCacheWriter *writer = [[MBCacheWriter alloc] initWithRegistry:_registry 
												   registryFileName: _registryFileName 
													  documentTypes: _documentTypes
															   ttls: _ttls
													   ttlsFileName: _ttlsFileName 
														   fileName: nil 
															   data: nil
											   temporaryMemoryCache: _temporaryMemoryCache
																key: nil];
	[_operationQueue addOperation: writer];
	[writer release];
}

-(void) deleteCachedFile:(NSString*) key {
	@synchronized(_registry) {
		NSString *fileName = [[_registry valueForKey: key] retain];
		[_registry removeObjectForKey:key];
		[_ttls removeObjectForKey:key];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:[self determineAbsPath:fileName] error:NULL];
		[fileName release];
	}
}

-(void) doExpireDataForKey:(NSString*) key {
	[self deleteCachedFile:key];	
	[self flushRegistry];
}

-(void) doExpireAllDocuments {
	BOOL doneOne = FALSE;
	for(NSString *key in [_registry allKeys]) {
		NSRange range = [key rangeOfString:@":"];
		if(range.length >0) {
			NSString *documentName = [key substringToIndex:range.location];
			// Is it a valid document? If so delete the entry
			if([[MBMetadataService sharedInstance] definitionForDocumentName:documentName throwIfInvalid:FALSE] != nil) {
				[self deleteCachedFile: key];
				doneOne = TRUE;
			}
		}
	}
	if(doneOne) [self flushRegistry];
}

+(NSData*) dataForKey:(NSString*) key {
    return [[self sharedInstance] doGetValueForKey: key];
}

+(void) setData:(NSData*) data forKey:(NSString*) key timeToLive:(int) ttl {
    [[self sharedInstance] doSetValue: data forKey: key timeToLive:ttl];
}

+(MBDocument*) documentForKey:(NSString*) key {
    return [[self sharedInstance] doGetDocumentForKey: key];
}

+(void) setDocument:(MBDocument*) document forKey:(NSString*) key timeToLive:(int) ttl {
    [[self sharedInstance] doSetDocument: document forKey:(NSString*) key timeToLive:ttl];
}

+(void) expireDataForKey:(NSString*) key {
    return [[self sharedInstance] doExpireDataForKey: key];
}

+(void) expireDocumentForKey:(NSString*) key {
    return [[self sharedInstance] doExpireDataForKey: key];
}

+(void) expireAllDocuments {
    return [[self sharedInstance] doExpireAllDocuments];
}

@end
