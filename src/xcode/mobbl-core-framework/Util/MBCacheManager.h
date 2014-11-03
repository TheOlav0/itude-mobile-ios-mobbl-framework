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

#import "MBDocument.h"
#import "MBCaching.h"

@interface MBCacheManager : NSObject <MBCaching> {
    NSMutableDictionary *_registry;
    NSMutableDictionary *_documentTypes;
    NSMutableDictionary *_ttls;
    NSMutableDictionary *_temporaryMemoryCache;
    NSOperationQueue *_operationQueue;
    NSString *_registryFileName;
	NSString *_ttlsFileName;
}

+ (instancetype)sharedInstance;
+(void)setSharedInstance:(MBCacheManager*) instance;


+(NSData*) dataForKey:(NSString*) key DEPRECATED_MSG_ATTRIBUTE("use -dataForKey: instead");
+(void) setData:(NSData*) data forKey:(NSString*) key timeToLive:(int) ttl DEPRECATED_MSG_ATTRIBUTE("use -setData:forKey:timeToLive: instead");
+(void) expireDataForKey:(NSString*) key DEPRECATED_MSG_ATTRIBUTE("use -expireDataForKey: instead");
+(void) expireDocumentForKey:(NSString*) key DEPRECATED_MSG_ATTRIBUTE("use -expireDocumentForKey: instead");
+(void) expireAllDocuments DEPRECATED_MSG_ATTRIBUTE("use -documentForKey: instead");
+(MBDocument*) documentForKey:(NSString*) key DEPRECATED_MSG_ATTRIBUTE("use -documentForKey: instead");
+(void) setDocument:(MBDocument*) document forKey:(NSString*) key timeToLive:(int) ttl DEPRECATED_MSG_ATTRIBUTE("use -setDocument:forKey:timeToLive: instead");

/**
 Should only be used by subclasses of MBCacheManager!
 */
-(NSString*) determineAbsPath:(NSString*) fileName;

@end
