//
//  MBDefinitionTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 15/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDefinition.h"

@interface MBDefinitionTest : XCTestCase

@property(nonatomic, retain) MBDefinition *definition;

@end

@implementation MBDefinitionTest

- (void)setUp {
    [super setUp];
    self.definition = [[MBDefinition alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//Test return "name=value" as xml attribute (NSString)
- (void)testAttributeAsXML
{
    NSString *target = @" Test='Value'";
    NSString *result = [self.definition attributeAsXml:@"Test" withValue: @"Value"];
    XCTAssertTrue([target isEqualToString:result]);
    
    NSString *target2 = @"";
    NSString *result2 = [self.definition attributeAsXml:@"Test" withValue:nil];
    XCTAssertTrue([target2 isEqualToString:result2]);
}

//Test return "name=bool" as xml attribute (NSString)
-(void)testbooleanAsXml
{
    NSString *target = @" Test='TRUE'";
    NSString *result = [self.definition booleanAsXml:@"Test" withValue:true];
    XCTAssertTrue([target isEqualToString: result]);
}

//Test AsXmlWithLevel function, always returns empty string?
-(void)testAsXmlWithLevel
{
    XCTAssertEqual(@"", [self.definition asXmlWithLevel:0]);
}

//Test description, returns AsXmlWithLevel:0 so also always empty string
-(void)testDescription
{
    XCTAssertEqual(@"", [self.definition description]);
}



@end
