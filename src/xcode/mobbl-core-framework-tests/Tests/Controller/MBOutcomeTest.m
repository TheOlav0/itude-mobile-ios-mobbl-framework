//
//  MBOutcomeTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 15/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBOutcome.h"
#import "MBDocumentAbstractTest.h"

@interface MBOutcomeTest : MBDocumentAbstractTest
@property(nonatomic, retain) MBDocument *booksDoc;
@property(nonatomic, retain) MBOutcome *outCome;
@end

@implementation MBOutcomeTest

- (void)setUp {
    [super setUp];
    MBDocumentDefinition *docDef = [self.config definitionForDocumentName:@"Books" ];
    self.booksDoc = [[[MBDocumentFactory alloc] init] documentWithData:self.xmlDocumentData withType:PARSER_XML andDefinition:docDef];
    self.outCome = [[MBOutcome alloc] initWithOutcomeName:@"Test" document:self.booksDoc];
}

//Test isPreconditionValid method
-(void)testIsPreConditionValid
{
    //Withoud PreCondition, should always be true
    XCTAssertTrue([self.outCome isPreConditionValid]);
    
    //Test with valid condition, should always be true
    self.outCome.preCondition = @"1==1";
    XCTAssertTrue([self.outCome isPreConditionValid]);
    
    //Test with invalid condition, should always be false
    self.outCome.preCondition = @"1==0";
    XCTAssertFalse([self.outCome isPreConditionValid]);
    
    //Test with invalid input, should throw exception
    self.outCome.preCondition=@"InvalidInput";
    XCTAssertThrows([self.outCome isPreConditionValid]);
}

-(void)testInitWithOutcome
{
    MBOutcome *secondOutcom = [[MBOutcome alloc] initWithOutcome:self.outCome];
    XCTAssertTrue([[secondOutcom description] isEqualToString: [self.outCome description]]);
}

-(void)testInitWithOutcomePageStackName
{
    MBOutcome *secondOutcom = [[MBOutcome alloc] initWithOutcomeName:self.outCome.outcomeName document:self.booksDoc pageStackName:nil];
    XCTAssertTrue([[secondOutcom description] isEqualToString:[self.outCome description]]);
}

-(void)testInitWithOutcomeDefinition
{
    MBOutcomeDefinition *def = [[MBOutcomeDefinition alloc] init];
    def.name = self.outCome.outcomeName;
    
    MBOutcome *secondOutcom = [[MBOutcome alloc] initWithOutcomeDefinition:def];
    XCTAssertTrue([[secondOutcom description] isEqualToString:[self.outCome description]]);
}



@end
