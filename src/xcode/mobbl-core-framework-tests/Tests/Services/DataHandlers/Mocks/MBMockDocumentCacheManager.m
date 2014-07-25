//
//  MBMockCacheManager.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 23/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

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
