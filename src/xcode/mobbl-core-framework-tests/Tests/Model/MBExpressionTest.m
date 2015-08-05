//
//  MBExpressionTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 14/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"
#import "TestElementContainer.h"

@interface MBExpressionTest : XCTestCase


@end

@implementation MBExpressionTest

static NSString *EXPRESSION_IN = @"${index}${${blerp[${index}]}[${index}]}${index}";
static NSString *EXPRESSION_OUT = @"1Heuy!1";

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testSubstition
{
    TestElementContainer *tec = [[TestElementContainer alloc] init];
    NSString *out = [tec substituteExpressions:EXPRESSION_IN usingNilMarker:nil currentPath:nil];
    XCTAssertTrue([EXPRESSION_OUT isEqualToString:out]);
}

@end
