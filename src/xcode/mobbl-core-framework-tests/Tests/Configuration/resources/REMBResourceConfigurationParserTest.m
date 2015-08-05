//
//  REMBResourceConfigurationParserTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 04/08/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"

@interface REMBResourceConfigurationParserTest : XCTestCase
@property(nonatomic, retain) MBResourceConfigurationParser* parser;
@property(nonatomic, retain) NSArray* resourceIds;
@property(nonatomic, retain) NSArray* resourceValues;
@property(nonatomic, retain) NSArray* bundleIds;
@property(nonatomic, retain) NSArray* bundleValues;
@property(nonatomic, retain) NSData* data;
@end

@implementation REMBResourceConfigurationParserTest





- (void)setUp {
    [super setUp];
    self.parser = [[MBResourceConfigurationParser alloc] init];
    self.resourceIds = @[@"config", @"endpoints", @"ICON-tab_1", @"ICON-tab_2"];
    self.resourceValues = @[@"file://config.xml", @"file://endpoints.xml", @"file://ic_1.png", @"file://ic_2.png"];
    self.bundleIds = @[@"nl", @"fr"];
    self.bundleValues = @[@"file://texts-nl.xml", @"file://texts-nl.xml"];
    
    [self.parser setResourceAttributes:@[@"xmlns", @"id", @"url", @"cacheable", @"ttl"]];
    [self.parser setBundleAttributes:@[@"xmlns", @"languageCode", @"url"]];
    NSString * testPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"testresources" ofType:@"xml"];
    self.data = [[NSString stringWithContentsOfFile:testPath
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL] dataUsingEncoding:NSUTF8StringEncoding];
}

-(void)testResourceParsing
{
    MBResourceConfiguration* configuration = [self.parser parseData:self.data ofDocument:@"Resources"];
    //Test resources
    for(int i =0 ; i< [self.resourceIds count]; i++)
    {
        MBResourceDefinition* def = [configuration getResourceWithID:self.resourceIds[i]];
        XCTAssertTrue([self.resourceIds[i] isEqualToString: def.resourceId]);
        XCTAssertTrue([self.resourceValues[i] isEqualToString:def.url]);
        
        //TODO add some test to check cacheable and ttl
    }
}

-(void)testBundleParsing
{
    //TODO Create test for bundles with same language
    
    MBResourceConfiguration* configuration = [self.parser parseData:self.data ofDocument:@"Resources"];
    //Test bundles
    for(int i =0 ; i<[self.bundleIds count]; i++)
    {
        NSArray* bundles = [configuration bundlesForLanguageCode:self.bundleIds[i]];
        MBBundleDefinition* def = bundles[0];
        XCTAssertTrue([self.bundleIds[i] isEqualToString: def.languageCode]);
        XCTAssertTrue([self.bundleValues[i] isEqualToString:def.url]);
    }
    
}


@end
