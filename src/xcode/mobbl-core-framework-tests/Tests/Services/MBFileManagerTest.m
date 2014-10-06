/*
 * (C) Copyright Itude Mobile B.V., The Netherlands.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  MBFileManagerTest.m
//  mobbl-core-framework
//
//  Created by Sven Meyer on 14/07/14.

#import <XCTest/XCTest.h>

#import "MBFileManager.h"
#import "MBResourceService.h"

NSString * const ReadingTestFileName    =   @"MBFileManagerTest_read.xml";
NSString * const WritingTestFileName    =   @"MBFileManagerTest_write.xml";

NSString * const TestContentsString     =   @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                                            @"<root>\n"
                                            @"    <child>value</child>\n"
                                            @"</root>";

@interface MBFileManagerTest : XCTestCase

@end

@implementation MBFileManagerTest

- (MBFileManager *)fileManager {
    MBResourceService *resourceService = [MBResourceService sharedInstance];
    MBFileManager *fileManager = resourceService.fileManager;

    return fileManager;
}

- (NSData *)testData {
    return [TestContentsString dataUsingEncoding:NSStringEncodingConversionAllowLossy];
}

- (void) testDataWithContentsOfMainBundle {
    NSData *dataReadFromFile = [[self fileManager] dataWithContentsOfMainBundle:ReadingTestFileName];
    
    NSData *expectedData = [self testData];
    
    XCTAssertEqualObjects(dataReadFromFile, expectedData);
}

- (void) testWriteContents {
    [[self fileManager] writeContents:TestContentsString toFileName:WritingTestFileName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
    
    NSString *absoluteFilePath = [documentDirectory stringByAppendingPathComponent:WritingTestFileName];
    
    NSData *dataReadFromFile = [NSData dataWithContentsOfFile:absoluteFilePath];
    NSData *expectedData = [self testData];
    
    XCTAssertEqualObjects(dataReadFromFile, expectedData);
}

@end
