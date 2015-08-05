//
//  MBCacheWriterTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 20/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"

@interface MBCacheWriterTest : XCTestCase

@end

@implementation MBCacheWriterTest

- (void)setUp {
    [super setUp];
    [[MBMetadataService sharedInstance] setConfigName:@"config.xml"];
}

-(void)testLoadDocumentString
{
    MBDocument* testDoc = [[MBDataManagerService sharedInstance] loadDocument:@"Books"];
    MBElement* testElement = (MBElement *)[testDoc valueForPath:@"/Author[0]"];
    XCTAssertNotNil(testElement);
}

-(void)testStoreDocument
{
    MBDocument* testDoc = [[MBDataManagerService sharedInstance] loadDocument:@"Books"];
    MBDocument* copy = [testDoc copy];
    MBElement* testelement = [(MBElement *) copy valueForPath:@"/Author[0]/Book[0]"];
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    dateString = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    [testelement setValue:dateString forKey:@"isbn"];
    [[MBDataManagerService sharedInstance] storeDocument:copy];
    copy = [[MBDataManagerService sharedInstance] loadDocument:@"Books"];
    XCTAssertFalse([testDoc isEqualToDocument:copy]);
}
@end
