//
//  MBDocumentAbstractTest.m
//  mobbl-core-framework
//
//  Created by Olaf on 13/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//
#import "MBDocumentAbstractTest.h"

@implementation MBDocumentAbstractTest


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString* jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"testdocument" ofType:@"txt"];
    self.jsonDocumentData = [[NSString stringWithContentsOfFile:jsonPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * xmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"testdocument" ofType:@"xml"];
    self.xmlDocumentData = [[NSString stringWithContentsOfFile:xmlPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL]dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * configPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"config_unittests" ofType:@"xml"];
    self.configData = [[NSString stringWithContentsOfFile:configPath
                                                     encoding:NSUTF8StringEncoding
                                                         error:NULL] dataUsingEncoding:NSUTF8StringEncoding];
    
    MBMvcConfigurationParser *configParser = [[MBMvcConfigurationParser alloc] init];
    self.config = [configParser parseData:_configData ofDocument:@"config"];
    
  
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


@end
