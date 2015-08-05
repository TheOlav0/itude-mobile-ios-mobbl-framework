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
@property(nonatomic, retain) MBDocument *document;
@property(nonatomic, retain) MBDocument *emptyDoc;
@property(nonatomic, retain) MBDataManagerService *dataManagerService;
@end

@implementation MBDocumentTest

- (void)setUp {
    [super setUp];
    self.dataManagerService = [[MockDataManagerService alloc] init];
    MBDocumentFactory *docFactory = [MBDocumentFactory sharedInstance];
    MBDocumentDefinition *docDef = [self.config definitionForDocumentName:@"Books"];
    self.document = [docFactory documentWithData:self.xmlDocumentData withType:PARSER_XML andDefinition:docDef];
    self.emptyDoc = [self.dataManagerService createDocument:@"Books"];
}

// Test the getter and setter of the sharedcontext
- (void)testSetSharedContext {
    NSMutableDictionary *sharedContext = [[NSMutableDictionary alloc] init];
    [sharedContext setObject:self.document forKey:@"test" ];
    self.document.sharedContext = sharedContext;
    XCTAssertEqual(self.document.sharedContext, sharedContext);
}

//Test the isEqualToDocument function
-(void)testIsEqualToDocument
{
    XCTAssertTrue([self.document isEqualToDocument:self.document]);
}

// test if a document is correctly assigned
-(void)testAssignToDocument {
    [self.document assignToDocument:self.document];
    XCTAssertTrue([self.document isEqualToDocument:self.document]);
}

//Test make copy
-(void)testCopy
{
    MBDocument *newDoc = [self.document copy];
    XCTAssertTrue([self.document isEqualToDocument:newDoc]);
}

//Test Clear all Chaches for dictionary sharedContext.
-(void)testClearAllCaches
{
    NSMutableDictionary *sharedContext = [[NSMutableDictionary alloc] init];
    [sharedContext setObject:self.document forKey:@"test"];
    self.document.sharedContext = sharedContext;
    XCTAssertNotNil(self.document.sharedContext[@"test"]);
    [self.document clearAllCaches];
    XCTAssertNil(self.document.sharedContext[@"test"]);
}

//Reload test using a mocked dataHandler
-(void)testReload
{
    NSString *name = [self.emptyDoc name];
    [self.emptyDoc reload];
    XCTAssertEqual([self.emptyDoc name], name);
    
    [self.emptyDoc setArgumentsUsed:self.emptyDoc];
    [self.emptyDoc reload];
    XCTAssertEqual([[self.emptyDoc argumentsUsed] name], name);
}



//Test if the getDocument function returns the correct instance
-(void)testGetDocument
{
    MBDocument* doc = [self.document document];
    XCTAssertEqual(doc, self.document);
}

//Test Value For Path to return the right value
-(void)testValueForPath
{
    NSString *target = @"test";
    NSString *value = [self.document valueForPath:@"/Author[0]/@name"];
    XCTAssertTrue([target isEqualToString:value]);
}

//Test if writing asXmlWithLevel works
-(void)testWritingAsXMLWithLevel
{
    self.document = [self.dataManagerService createDocument:@"testdocument"];
    NSString *xmlString = [self.document asXmlWithLevel:0];
    XCTAssertNotNil(xmlString);
}

//Test if uniqueId works
-(void)testUniqueId
{
    MBDocument *copy = [self.document copy];
    NSString *id1 = [self.document uniqueId];
    NSString *id2 = [copy uniqueId];
    XCTAssertNotEqual(id1,id2);
}

@end


