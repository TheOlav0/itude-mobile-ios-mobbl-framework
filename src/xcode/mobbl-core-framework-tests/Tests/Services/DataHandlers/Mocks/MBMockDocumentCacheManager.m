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
//  MBMockCacheManager.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 23/07/14.

#import "MBMockDocumentCacheManager.h"
#import "MBDocument.h"

@interface MBMockDocumentCacheManager()

@property (nonatomic, retain) NSMutableDictionary *cacheItems;

@end

@implementation MBMockDocumentCacheManager

#pragma mark - Object lifecycle

- (id)initWithCacheItems:(NSDictionary *)cacheItems {
    self = [super init];
    if (self) {
        if (cacheItems) {
            _cacheItems = [cacheItems mutableCopy];
        } else {
            _cacheItems = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
    [_cacheItems release];
    [super dealloc];
}

- (MBDocument *)documentForKey:(NSString *)key {
    MBDocument *document = self.cacheItems[key];
    
    return document;
}

- (void)setDocument:(MBDocument *)document forKey:(NSString *)key timeToLive:(NSUInteger)timeToLive {
    self.cacheItems[key] = document;
}

- (void)expireDocumentForKey:(NSString *)key {
    [self.cacheItems removeObjectForKey:key];
}

- (void)expireAllDocuments {
    NSMutableDictionary *newCacheItems = [[NSMutableDictionary alloc] init];
    
    self.cacheItems = newCacheItems;
    
    [newCacheItems release];
}

@end
