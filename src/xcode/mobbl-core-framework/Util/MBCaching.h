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
