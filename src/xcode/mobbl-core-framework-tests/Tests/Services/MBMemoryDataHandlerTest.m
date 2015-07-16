//
//  MBMemoryDataHandlerTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 16/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"

@interface MBMemoryDataHandlerTest : MBDocumentAbstractTest

@end

@implementation MBMemoryDataHandlerTest

- (void)setUp {
    [super setUp];
    
    [[MBMetadataService sharedInstance ]setConfigName:@"config.xml"];
}

-(void)testLoadDocument
{
    MBDocument *doc = [[MBDataManagerService sharedInstance] loadDocument:@"TestDocument1"];
    XCTAssertNotNil(doc);
}

-(void)testStoreDocument
{
    MBDocument *document = [[MBDataManagerService sharedInstance] loadDocument:@"TestDocument1"];
    MBDocument *copy = [document copy];
    MBElement *element = [copy valueForPath:@"/LoginInfo[0]"];
    NSString *testValue = @"LoginMessage value";
    [element setValue:testValue forAttribute:@"LoginMessage"];
    [[MBDataManagerService sharedInstance] storeDocument:copy];
    copy = [[MBDataManagerService sharedInstance] loadDocument:@"TestDocument1"];
    XCTAssertFalse([copy isEqualToDocument:document]);
    
    //Reset the data, otherwise next test will fail.
    element = [copy valueForPath:@"/LoginInfo[0]"];
    testValue = @"default login message";
    [element setValue:testValue forAttribute:@"LoginMessage"];
    [[MBDataManagerService sharedInstance] storeDocument:copy];
}

@end
