//
//  MBMvcConfigurationParserTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 04/08/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"

@interface MBMvcConfigurationParserTest : XCTestCase
@property(nonatomic, retain) MBMvcConfigurationParser* parser;
@property(nonatomic, retain) MBConfigurationDefinition* config;
@property(nonatomic, retain) NSData* data;

@end

@implementation MBMvcConfigurationParserTest

- (void)setUp {
    [super setUp];
    self.parser = [[MBMvcConfigurationParser alloc] init];
    if(!self.config)
    {
        NSString * configPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"config_unittests" ofType:@"xml"];
        self.data = [[NSString stringWithContentsOfFile:configPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL] dataUsingEncoding:NSUTF8StringEncoding];
        self.config = [self.parser parseData:self.data ofDocument:@"Config"];
    }
}

-(void)testConfigParsing
{
    XCTAssertNotNil(self.config);
}

-(void)testDocumentsElementsAndAttrbutes
{
    MBDocumentDefinition* docDef = [self.config definitionForDocumentName:@"Books"];
    XCTAssertNotNil(docDef);
    
    MBElementDefinition* resultDef = [docDef childWithName:@"Author"];
    XCTAssertNotNil(resultDef);
    
    MBElementDefinition* childDef = [resultDef childWithName:@"Book"];
    XCTAssertTrue([@"Book" isEqualToString: [childDef name]]);
    
    XCTAssertEqual(8, [[childDef attributes] count]);
    
    NSMutableArray* attributes = (NSMutableArray*)[[childDef attributeNames] componentsSeparatedByString:@","];
    for(MBAttributeDefinition* attribute in attributes)
    {
        XCTAssertNotNil(attribute);
    }
    
}

-(void)testActions
{
    NSArray* actions = [self.config.actions allKeys];
    for(NSString* action in actions)
    {
        MBActionDefinition* actionDef = self.config.actions[action];
        XCTAssertNotNil(actionDef);
        XCTAssertEqual(action, actionDef.className);
        XCTAssertEqual(action, actionDef.name);
    }
}

-(void)testOutcomes
{
    XCTAssertEqual(10, [self.config.outcomes count]);
    NSArray* outcomes = [self.config outcomeDefinitionsForOrigin:@"PAGE-tab_1" outcomeName:@"OUTCOME-page_1"];
    XCTAssertNotNil(outcomes);
    XCTAssertEqual(2, [outcomes count]);
    
    for(int i = 0; i < [outcomes count]; i++)
    {
        MBOutcomeDefinition* outDef = outcomes[i];
        XCTAssertNotNil(outDef);
        XCTAssertTrue([@"PAGE-tab_1" isEqualToString: outDef.origin]);
        XCTAssertTrue([@"OUTCOME-page_1" isEqualToString: outDef.name]);
    

        if (i == 0)
        {
            XCTAssertTrue([@"!${SessionState:Session[0]/@loggedIn}" isEqualToString:outDef.preCondition]);
            XCTAssertTrue([@"PAGE-page_1" isEqualToString: outDef.action]);
            XCTAssertTrue([@"MODAL" isEqualToString: outDef.displayMode]);
        }
        else
        {
            XCTAssertTrue([@"${SessionState:Session[0]/@loggedIn}" isEqualToString: outDef.preCondition]);
            XCTAssertTrue([@"Page1Action" isEqualToString: outDef.action]);
        }
    }
    
}

-(void)testDialog
{
    NSArray* configDialogs = [self.config.dialogs allValues];
    XCTAssertNotNil(configDialogs);
    for(int i = 0; i < [configDialogs count]; i++)
    {
        int num = i +1;
        NSString* title = [NSString stringWithFormat:@"Tab %d", num];
        NSString* icon = [NSString stringWithFormat:@"ICON-tab_%d", num];
        NSString* dialog= [NSString stringWithFormat:@"DIALOG-tab_%d",num];
        MBDialogDefinition* configDialogDef = configDialogs[i];
        XCTAssertTrue([@"STACK" isEqualToString:configDialogDef.mode]);
        XCTAssertTrue([title isEqualToString:configDialogDef.title]);
        XCTAssertTrue([icon isEqualToString:configDialogDef.iconName]);
        XCTAssertTrue([dialog isEqualToString:configDialogDef.name]);
        
    }
}

-(void)testPages
{
    XCTAssertEqual(2, [self.config.pages count]);
    MBPageDefinition* pageDef = [self.config definitionForPageName:@"PAGE-page_1"];
    XCTAssertNotNil(pageDef);
    
    XCTAssertTrue([@"MBEmptyDoc" isEqualToString:pageDef.documentName]);
    XCTAssertTrue([@"Page title" isEqualToString:pageDef.title]);
    XCTAssertEqual(1, [pageDef.children count]);
    
    MBPanelDefinition* panelDef = pageDef.children[0];
    XCTAssertNotNil(panelDef);
    XCTAssertEqual(2, [panelDef.children count]);
    
    MBPanelDefinition* subPanel = panelDef.children[0];
    XCTAssertNotNil(subPanel);
    XCTAssertTrue([@"SECTION" isEqualToString:subPanel.type]);
    XCTAssertTrue([@"${SessionState:Session[0]/@loggedIn}" isEqualToString:subPanel.preCondition]);
    XCTAssertTrue([@"Header title" isEqualToString:subPanel.title]);
}

-(void)testDomainAndDomainValidators
{
    XCTAssertEqual(2, [self.config.domains count]);
    
    NSArray* domains = [self.config.domains allValues];
    for(MBDomainDefinition* domain in domains)
    {
        XCTAssertNotNil(domain);
    }
    
    MBDomainDefinition* months = [self.config definitionForDomainName:@"list_months"];
    XCTAssertNotNil(months);
    XCTAssertTrue([@"list_months" isEqualToString:months.name]);
    XCTAssertTrue([@"string" isEqualToString:months.type]);
    XCTAssertEqual(12, [months.domainValidators count]);
    
    NSArray* monthValues = @[@"Januari",
                             @"Februari",
                             @"Maart",
                             @"April",
                             @"Mei",
                             @"Juni",
                             @"Juli",
                             @"Augustus",
                             @"September",
                             @"Oktober",
                             @"November",
                             @"December"];
    
    for(int i = 0; i < [months.domainValidators count]; i++)
    {
        int num = i +1;
        MBDomainValidatorDefinition* domValDef = months.domainValidators[i];
        XCTAssertNotNil(domValDef);
        XCTAssertTrue([monthValues[i] isEqualToString:domValDef.title]);
        NSString* temp = [NSString stringWithFormat:@"%d", num ];
        XCTAssertTrue([temp isEqualToString: domValDef.value]);
    }
    
}

@end
