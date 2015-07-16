//
//  MBFileDataHandlerTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 16/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"

@interface MBFileDataHandlerTest : MBDocumentAbstractTest

@end

@implementation MBFileDataHandlerTest

- (void)setUp {
    [super setUp];
}

-(void)testLoadDocument
{
    MBDocument *document = [[MBDataManagerService sharedInstance] loadDocument:@"Books"];
    MBElement *author = [document valueForPath:@"/Author[0]"];
    XCTAssertNotNil(author);
}

//Test store data in a document
-(void)testStoreDocument
{
    MBDocument *document = [[MBDataManagerService sharedInstance] loadDocument:@"Books"];
    MBDocument *copy = [document copy];
    MBElement *element = [copy valueForPath:@"/Author[0]/Book[0]"];
    NSString *testValue = @"ThisIsATestISBN";
    [element setValue:testValue forAttribute:@"isbn"];
    [[MBDataManagerService sharedInstance] storeDocument:copy];
    copy = [[MBDataManagerService sharedInstance] loadDocument:@"Books"];
    XCTAssertFalse([copy isEqualToDocument:document]);
    
    //Reset the data, otherwise next test will fail.
    element = [copy valueForPath:@"/Author[0]/Book[0]"];
    testValue = @"9519345";
    [element setValue:testValue forAttribute:@"isbn"];
    [[MBDataManagerService sharedInstance] storeDocument:copy];
    
}


@end
