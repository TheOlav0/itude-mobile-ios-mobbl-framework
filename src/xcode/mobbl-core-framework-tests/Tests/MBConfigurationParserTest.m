//
//  MBConfigurationParserTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 15/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBConfigurationParser.h"

@interface MBConfigurationParserTest : XCTestCase
@property(nonatomic,retain) MBConfigurationParser *parser;
@end

@implementation MBConfigurationParserTest

- (void)setUp {
    [super setUp];
    self.parser = [[MBConfigurationParser alloc] init];
    
}

//Test for validAttributes in a NSdictionary
-(void)testCheckAttributesForElement
{
    //Valid
    NSDictionary *dict = [[NSDictionary alloc]initWithObjects:@[@"Value"] forKeys:@[@"Test"]];
    NSArray *valids = @[@"Test"];
    XCTAssertTrue([self.parser checkAttributesForElement:@"TestAttributes" withAttributes:dict withValids:valids]);
    
    //Invalid
    NSDictionary *dict2 = [[NSDictionary alloc]initWithObjects:@[@"Value"] forKeys:@[@"WrongTest"]];
    NSArray *valids2 = @[@"Test"];
    XCTAssertFalse([self.parser checkAttributesForElement:@"TestAttributes" withAttributes:dict2 withValids:valids2]);
}



@end
