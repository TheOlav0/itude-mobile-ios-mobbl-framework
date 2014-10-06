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
//  MBCaching.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 23/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

@class MBDocument;

@protocol MBDataCaching;
@protocol MBDocumentCaching;

@protocol MBCaching <MBDataCaching, MBDocumentCaching>
@end

@protocol MBDataCaching <NSObject>

- (NSData *) dataForKey:(NSString *) key;
- (void) setData:(NSData *) data forKey:(NSString*) key timeToLive:(NSUInteger) ttl;
- (void) expireDataForKey:(NSString *) key;

@end

@protocol MBDocumentCaching <NSObject>

- (void) expireDocumentForKey:(NSString *) key;
- (void) expireAllDocuments;
- (MBDocument *) documentForKey:(NSString *) key;
- (void) setDocument:(MBDocument *) document forKey:(NSString *) key timeToLive:(NSUInteger) timeToLive;

@end
