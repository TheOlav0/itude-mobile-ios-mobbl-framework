//
//  MBMockCacheManager.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 23/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBCaching.h"

@interface MBMockDocumentCacheManager : NSObject <MBDocumentCaching>

- (id)initWithCacheItems:(NSDictionary *)cacheItems;

@end
