//
//  MBDocumentDiffTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 16/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MBDocumentAbstractTest.h"
#import "MBDocumentDiff.h"
#import "MockDataManagerService.h"

@interface MBDocumentDiffTest : MBDocumentAbstractTest
@property(nonatomic, retain) MBDocument *documentA;
@property(nonatomic, retain) MBDocument *documentB;
@property(nonatomic, retain) MBDocumentDiff *docDifference;
@property(nonatomic, retain) MBDataManagerService *dataManagerService;
@end

@implementation MBDocumentDiffTest

- (void)setUp {
    [super setUp];
    self.dataManagerService = [[MockDataManagerService alloc] init];
    self.documentA = [self.dataManagerService createDocument:@"testdocument"];
    self.documentB = [self.dataManagerService createDocument:@"testdocument"];
    self.docDifference = [[MBDocumentDiff alloc] initWithDocumentA:self.documentA andDocumentB:self.documentB];
}

//Test InitWithDocument
-(void)testInitWithDocument
{
    XCTAssertNotNil(self.docDifference);
}

//Test setted paths
-(void)testPaths
{
    NSSet *theModified = [self.docDifference paths];
    XCTAssertEqual([theModified count], 0);
}

//Test Is Changed, gives false, when all paths are the same.
-(void)testIsChanged
{
    XCTAssertFalse([self.docDifference isChanged]);
}

-(void)testIsChangedFindByPath
{
    XCTAssertFalse([self.docDifference isChanged:@"Author[0"]);
}

-(void)testValueOfPathAB
{
    XCTAssertNil([self.docDifference valueOfAForPath:@""]);
    XCTAssertNil([self.docDifference valueOfBForPath:@""]);
}







@end
