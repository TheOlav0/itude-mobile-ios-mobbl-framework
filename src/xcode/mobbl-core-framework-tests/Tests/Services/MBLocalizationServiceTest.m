////
//  MBLocalizationService.m
//  mobbl-core-framework
//
//  Created by Olaf on 20/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBMetadataService.h"
#import "MBLocalizationService.h"

@interface MBLocalizationServiceTest : XCTestCase

@end

@implementation MBLocalizationServiceTest

- (void)setUp {
    [super setUp];
    [[MBMetadataService sharedInstance] setConfigName:@"config.xml"];
}

-(void)testService
{
    MBLocalizationService *locService = [MBLocalizationService sharedInstance];
    XCTAssertNotNil(locService);
}

-(void)testText
{
    NSString *text = [[MBLocalizationService sharedInstance] textForKey:@"normal"];
    XCTAssertTrue([text isEqualToString:@"Normaal"]);
}

//Test Text with arguments: see Resources/Config/text-nl.xml
-(void) testTextWithArguments
{
    NSNumber *number =  @2;
    NSString *text = [[MBLocalizationService sharedInstance] textForKey:@"substitution" withArguments: number];
    XCTAssertTrue([text isEqualToString:@"Er zijn 2 variabelen"]);
    
    text = [[MBLocalizationService sharedInstance] textForKey:@"substitution"];
    XCTAssertNotNil(text);
}

@end