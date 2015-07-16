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
@property(nonatomic, retain) MBDocumentFactory *docFactory;
@end

@implementation MBDocumentFactoryTest

- (void)setUp {
    [super setUp];
    self.docFactory = [[MBDocumentFactory alloc] init];
}

//Test RegisterDocumentParser to set new parsers, and getter ParseForType who gets the DocumentParser.
-(void)testParserForType
{
    [self.docFactory registerDocumentParser:[[MBXmlDocumentParser new] autorelease] withName:@"Test"];
    MBDocumentDefinition *docDef = [self.config definitionForDocumentName:@"Books"];
    XCTAssertNotNil(docDef);
    MBDocument *doc = [self.docFactory documentWithData:self.xmlDocumentData withType:@"Test" andDefinition:docDef];
    XCTAssertNotNil(doc);
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

@end
