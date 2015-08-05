//
//  MBConditionalDefinitionTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 15/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBConditionalDefinition.h"
#import "MockDataManagerService.h"
#import "MBDataManagerService.h"

@interface MBConditionalDefinitionTest : XCTestCase
@property(nonatomic, retain) MBConditionalDefinition *definition;
@property(nonatomic, retain) MBDocument *document;
@end

@implementation MBConditionalDefinitionTest

- (void)setUp {
    [super setUp];
    self.definition = [[MBConditionalDefinition alloc] init];
    self.document = [[MBDataManagerService sharedInstance] loadDocument:@"MBEmpty"];
}

- (void)tearDown {
    [super tearDown];
}

//Test if Precondition is valid/unvalid/exception.
- (void)testIsPreConditionValid
{
    XCTAssertTrue([_definition isPreConditionValid]);
    
    self.definition.preCondition =@"'test1'=='test1'";
    XCTAssertTrue([self.definition isPreConditionValid]);
    
    self.definition.preCondition =@"1==0";
    XCTAssertFalse([self.definition isPreConditionValid]);

    
    self.definition.preCondition = @"NotValidPrecondition";
    XCTAssertThrows([self.definition isPreConditionValid]);
}


//Test if precondition is valid/unvalid/exception on document (not sure if it does something).
-(void)testIsPreConditionValidOfDocument
{
   self.definition.preCondition=@"1==1";
    XCTAssertTrue([self.definition isPreConditionValid:self.document currentPath:nil]);
    
    self.definition.preCondition =@"1==0";
    XCTAssertFalse([self.definition isPreConditionValid:self.document currentPath:@""]);
    
    self.definition.preCondition = @"NotValidPrecondition";
    XCTAssertThrows([self.definition isPreConditionValid:self.document currentPath:@""]);

    
}

@end
