//
//  MBCacheManagerTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 20/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"

@interface MBCacheManagerTest : XCTestCase
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSData *textData;
@property(nonatomic, retain) MBDocument* testDocument;
@end

@implementation MBCacheManagerTest

- (void)setUp
{
    [super setUp];
    [[MBMetadataService sharedInstance] setConfigName:@"config_unittests.xml"];
    [[MBMetadataService sharedInstance] setEndpointsName:@"endpoints.xml"];
    self.text =@"Test String for Testing the MBCacheManager";
    self.textData = [ self.text dataUsingEncoding:NSUTF8StringEncoding];
    self.testDocument = [[MBDataManagerService sharedInstance] loadDocument:@"MBGenericRestRequest"];
}

-(void)testCache
{
    //Test setting data in the cache
    [self doPutInCache:@"test" withData:self.textData timeToLive:0];
    [self doGetFromCache:@"test" expectedResult:self.textData];
    
    //Test empty cache with live time
    [self doPutInCache:@"test" withData:self.textData timeToLive:1];
    [self doGetFromCache:@"test" expectedResult:nil];
    
    //Test empty cache
    [self doGetFromCache:@"ThisShouldBeEmpty" expectedResult:nil];
    
}

//Test expiration in cache
-(void)testExpiration{
    
    //Try to set data in the cached
    [self doPutInCache:@"test" withData:self.textData timeToLive:0];
    [self doGetFromCache:@"test" expectedResult:self.textData];
    
    //Expire the data for @"test"
    [[MBCacheManager sharedInstance] expireDataForKey:@"test"];
    [self doGetFromCache:@"test" expectedResult:nil];
}

-(void)testCacheADocument
{
    //Test set a document in cache
    [self doPutDocumentInCache:@"testDoc" withDocument:self.testDocument timeToLive:0];
    [self doGetDocumentFromCache:@"testDoc" withExpectedDocument:self.testDocument];
    
    //Test empyt cache with live time
    [self doPutDocumentInCache:@"testDoc" withDocument:self.testDocument timeToLive:1];
    [self doGetDocumentFromCache:@"testDoc" withExpectedDocument:nil];
    
    //Test empty cache
    [self doGetDocumentFromCache:@"ThisShouldBeEmpty" withExpectedDocument:nil];
    
}

-(void)testExpireDocument
{
    [self doPutDocumentInCache:@"testDoc" withDocument:self.testDocument timeToLive:0];
    [self doGetDocumentFromCache:@"testDoc" withExpectedDocument:self.testDocument];
    
    [[MBCacheManager sharedInstance] expireDocumentForKey:@"testDoc"];
    [self doGetDocumentFromCache:@"testDoc" withExpectedDocument:nil];
}

-(void)testExpireAllDocuments
{
    //Put documents in cache
    [self doPutDocumentInCache:self.testDocument.uniqueId withDocument:self.testDocument timeToLive:0];
    [self doGetDocumentFromCache:self.testDocument.uniqueId withExpectedDocument:self.testDocument];
    
    MBDocument* secondDoc = [[MBDataManagerService sharedInstance] loadDocument:@"MBEmptyDoc"];
    [self doPutDocumentInCache:secondDoc.uniqueId withDocument: secondDoc timeToLive:0];
    [self doGetDocumentFromCache:secondDoc.uniqueId withExpectedDocument: secondDoc];
    
    [[MBCacheManager sharedInstance] expireAllDocuments];
    [NSThread sleepForTimeInterval:2];
    [self doGetDocumentFromCache:self.testDocument.uniqueId withExpectedDocument:nil];
    [self doGetDocumentFromCache:secondDoc.uniqueId withExpectedDocument:nil];
}

-(void)doPutInCache: (NSString *) key withData:(NSData *) data timeToLive: (int) ttl
{
    [[MBCacheManager sharedInstance] setData:data forKey:key timeToLive:ttl];
    //Wait for 2 seconds to set the data
    [NSThread sleepForTimeInterval:2];
}

-(void)doPutDocumentInCache: (NSString *) key withDocument: (MBDocument *) document timeToLive:(int) ttl
{
    [[MBCacheManager sharedInstance] setDocument:document forKey:key timeToLive:ttl];
    [NSThread sleepForTimeInterval:2];
}

//Method to retrieve data and test it.
-(void)doGetFromCache: (NSString *)key expectedResult: (NSData *) expected
{
    NSData* results = [[MBCacheManager sharedInstance] dataForKey:key];
    if(!expected)
    {
        XCTAssertNil(results);
    }
    else
    {
        XCTAssertEqual(results, expected);
    }
}

-(void)doGetDocumentFromCache: (NSString *)key withExpectedDocument:(MBDocument *) expected
{
    MBDocument* result = [[MBCacheManager sharedInstance] documentForKey:key];
    if(!expected) XCTAssertNil(result);
    else XCTAssertTrue([expected isEqualToDocument:result]);
}

-(void)tearDown
{
    [super setUp];
}

@end
