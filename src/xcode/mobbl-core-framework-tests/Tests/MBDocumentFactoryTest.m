//
//  MBDocumentFactoryTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 14/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"

@interface MBDocumentFactoryTest : MBDocumentAbstractTest

@end

@implementation MBDocumentFactoryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJsonParsing
{
    XCTAssertNotNil(self.jsonDocumentData);
    XCTAssertNotNil(self.configData);
    XCTAssertNotNil(self.config);
    
    MBDocumentDefinition *docDef = [self.config definitionForDocumentName:@"Books"];
    XCTAssertNotNil(docDef);
    MBDocumentFactory *documentFactory = [[MBDocumentFactory alloc] init];
    XCTAssertNotNil(documentFactory);
    
    MBDocument *document = [documentFactory documentWithData:self.jsonDocumentData withType:PARSER_JSON andDefinition:docDef];
    XCTAssertNotNil(document);
}

-(void)testXMLParsing
{
    XCTAssertNotNil(self.xmlDocumentData);
    XCTAssertNotNil(self.configData);
    XCTAssertNotNil(self.config);
    
    MBDocumentDefinition *docDef = [self.config definitionForDocumentName:@"Books"];
    XCTAssertNotNil(docDef);
    MBDocumentFactory *documentFactory = [[MBDocumentFactory alloc] init];
    XCTAssertNotNil(documentFactory);
    
    MBDocument *document = [documentFactory documentWithData:self.xmlDocumentData withType:PARSER_XML andDefinition:docDef];
    XCTAssertNotNil(document);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
