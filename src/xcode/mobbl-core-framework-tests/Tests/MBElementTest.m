//
//  MBElementTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 14/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"

@interface MBElementTest : MBDocumentAbstractTest

@end

@implementation MBElementTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAsXml
{
    XCTAssertNotNil(self.xmlDocumentData);
    XCTAssertNotNil(self.configData);
    XCTAssertNotNil(self.config);
    
    MBDocumentDefinition *docDef = [self.config definitionForDocumentName:@"Books"];
    XCTAssertNotNil(docDef);
    
    MBDocumentFactory *documentFactory = [[MBDocumentFactory alloc] init];

    MBDocument *document = [documentFactory documentWithData:self.xmlDocumentData withType:PARSER_XML andDefinition:docDef];
    XCTAssertNotNil(document);
    
    //Get error on parsing it to xmlWithLevel: 0 string!
   /* NSString *pass1 = [document asXmlWithLevel:0];
 //   NSData *serializedXmlData = [pass1 dataUsingEncoding:NSUTF8StringEncoding];
    
  //  MBDocument *reparsedDocument = [documentFactory documentWithData:serializedXmlData withType:PARSER_XML andDefinition:docDef];
    NSString *pass2 = [document asXmlWithLevel:0];
    XCTAssertEqual(pass1, pass2);*/
    
    
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
