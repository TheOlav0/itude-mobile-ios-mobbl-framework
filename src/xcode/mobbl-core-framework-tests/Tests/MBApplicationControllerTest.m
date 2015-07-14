//
//  MBApplicationControllerTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 14/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"
#import "MBApplicationController.h"

@interface MBApplicationControllerTest : XCTestCase
@property(nonatomic,retain) MBApplicationController *app;
@end

@implementation MBApplicationControllerTest


- (void)setUp {
    [super setUp];
    _app = [[MBApplicationController alloc] init];
}

//Test instanciate of MBApllicationController
- (void)testGetInstance
{
    XCTAssertNotNil(_app);
}


@end
