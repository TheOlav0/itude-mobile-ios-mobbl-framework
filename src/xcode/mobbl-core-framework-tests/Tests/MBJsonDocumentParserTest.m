//
//  MBJsonDocumentParserTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 14/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"

@interface MBJsonDocumentParserTest : MBDocumentAbstractTest

@end

@implementation MBJsonDocumentParserTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJsonParsingWithData {
    XCTAssertNotNil(self.configData);
    XCTAssertNotNil(self.jsonDocumentData);
    
    MBMvcConfigurationParser *configParser = [[MBMvcConfigurationParser alloc] init];
    XCTAssertNotNil(configParser);
    MBConfigurationDefinition *config = [configParser parseData:self.configData ofDocument:@"config"];
    XCTAssertNotNil(config);
    MBDocumentDefinition *docDef = [config definitionForDocumentName:@"Books"];
    XCTAssertNotNil(docDef);
    
    MBJsonDocumentParser *parser = [[MBJsonDocumentParser alloc] init];
    MBDocument *document = [parser documentWithData:self.jsonDocumentData andDefinition:docDef];
    XCTAssertNotNil(document);
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
