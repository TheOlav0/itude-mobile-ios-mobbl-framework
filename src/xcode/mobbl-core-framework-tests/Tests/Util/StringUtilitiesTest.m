//
//  MBPathUtilTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 20/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"

@interface StringUtilitiesTest : XCTestCase

@end

@implementation StringUtilitiesTest

- (void)setUp {
    [super setUp];
    [[MBMetadataService sharedInstance] setConfigName:@"config_unittest.xml"];
    [[MBMetadataService sharedInstance] setEndpointsName:@"endpoints.xml"];
}

-(void)testStripCharacters
{
    NSString* testString = @"testString Where Character will Be removed";
    NSString* removeChars =@"Be";
    NSString* result = [testString stripCharacters:removeChars];
    
    NSString* expected = @"tstString WhrCharactr will rmovd";
    
    XCTAssertTrue([result isEqualToString:expected]);
}

//Test of using StringUtilities split path
-(void)testSplitPath
{
    NSArray* paths = @[@"../a/b/c",@"a/b/c",@"/a/b/c", @""];
    NSArray* shoudBeComponents = [[NSArray alloc] init];
    
    //Test throw invalid path
    XCTAssertThrows([paths[0] splitPath]);
    
    //Test Valid path start with a
    NSArray* result = [paths[1] splitPath];
    shoudBeComponents = @[@"a", @"b", @"c"];
    XCTAssertTrue([result isEqualToArray:shoudBeComponents]);
    
    //Test Valid Path start with '/'
    result = [paths[2] splitPath];
    XCTAssertTrue([result isEqualToArray:shoudBeComponents]);
    
    //Test Empty path
    result = [paths[3] splitPath];
    shoudBeComponents = [[NSArray alloc] init];
    XCTAssertTrue([result isEqualToArray:shoudBeComponents]);
    
}

-(void)testNormalizedPath
{
    //Test an already normalizedpath
    NSString* path = @"Author[0]/Books[0]";
    NSString* expected = @"Author[0]/Books[0]";
    NSString* result = [path normalizedPath];
    XCTAssertTrue([result isEqualToString: expected]);
    
    //Test an already normalizedPath with prefix "/"
    NSString* path2 = @"/Author[0]/Books[0]";
    NSString* expected2 = @"/Author[0]/Books[0]";
    NSString* result2 = [path2 normalizedPath];
    XCTAssertTrue([result2 isEqualToString: expected2]);
    
    //Test with "/" and "." characters
    NSString* path3 = @"//Author[0]/./Books[0]";
    NSString* expected3 = @"/Author[0]/Books[0]";
    NSString* result3 = [path3 normalizedPath];
    XCTAssertTrue([result3 isEqualToString: expected3]);
    
}

@end
