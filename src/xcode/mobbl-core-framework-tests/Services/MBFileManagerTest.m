//
//  MBFileManagerTest.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 14/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MBResourceService.h"

NSString * const ReadTestFileName = @"MBFileManagerReadTest.xml";
NSString * const ReadTestFileContents = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                        @"<root>\n"
                                        @"    <child>value</child>\n"
                                        @"</root>";

@interface MBFileManagerTest : XCTestCase

@end

@implementation MBFileManagerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testDataWithContentsOfMainBundle {
    MBResourceService *resourceService = [MBResourceService sharedInstance];
    MBFileManager *fileManager = resourceService.fileManager;
    
    NSData *dataReadFromFile = [fileManager dataWithContentsOfMainBundle:ReadTestFileName];
    
    NSData *expectedData = [ReadTestFileContents dataUsingEncoding:NSStringEncodingConversionAllowLossy];

    XCTAssertEqualObjects(dataReadFromFile, expectedData);
}

- (void) testWriteContents {
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
