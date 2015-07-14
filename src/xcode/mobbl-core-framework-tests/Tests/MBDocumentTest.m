//
//  MBDocumentTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 13/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"
#import "MockDataManagerService.h"

@interface MBDocumentTest : MBDocumentAbstractTest
@property(nonatomic, retain) MBDocument *emptyDoc;
@end

@implementation MBDocumentTest

- (void)setUp {
    [super setUp];
    MBDataManagerService *dataManagerService = [[MockDataManagerService alloc] init];
    _emptyDoc = [dataManagerService createDocument:@"testDocument"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test the getter and setter of the sharedcontext
- (void)testSetSharedContext {
    NSMutableDictionary *sharedContext = [[NSMutableDictionary alloc] init];
    [sharedContext setObject:self.emptyDoc forKey:@"test" ];
    self.emptyDoc.sharedContext = sharedContext;
    XCTAssertEqual(self.emptyDoc.sharedContext, sharedContext);
}

//Test the isEqualToDocument function
-(void)testIsEqualToDocument
{
    XCTAssertTrue([self.emptyDoc isEqualToDocument:self.emptyDoc]);
}

// test if a document is correctly assigned
-(void)testAssignToDocument {
    [self.emptyDoc assignToDocument:self.emptyDoc];
    XCTAssertTrue([self.emptyDoc isEqualToDocument:self.emptyDoc]);
}

//Reload test and loadFreshCopy test not yet implemented duo MBDataManagerService error, it doesn't take a instance of MockDataManagerService.
/*-(void)testReload
{
    NSString *name = [self.emptyDoc name];
    [_emptyDoc reload];
    XCTAssertEqual([self.emptyDoc name], name);
    
    [self.emptyDoc setArgumentsUsed:self.emptyDoc];
    [self.emptyDoc reload];
    XCTAssertEqual([[self.emptyDoc argumentsUsed] name], name);
}*/

//Test if the getDocument function returns the correct instance
-(void)testGetDocument
{
    MBDocument* doc = [_emptyDoc document];
    XCTAssertEqual(doc, _emptyDoc);
}

//Test if writing asXmlWithLevel works
-(void)testWritingAsXMLWithLevel
{
    NSString *xmlString = [_emptyDoc asXmlWithLevel:0];
    XCTAssertNotNil(xmlString);
}

//Test if uniqueId works
-(void)testUniqueId
{
    MBDocument *copy = [_emptyDoc copy];
    NSString *id1 = [_emptyDoc uniqueId];
    NSString *id2 = [copy uniqueId];
    XCTAssertNotEqual(id1,id2);
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end


