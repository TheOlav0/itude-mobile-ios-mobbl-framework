//
//  MBDocumentAbstractTest.h
//  mobbl-core-framework
//
//  Created by Olaf on 13/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "mobbl_core_framework.h"
#import "MBEndPointDefinition.h"
#import "MBDocumentDefinition.h"
#import "MBDataManagerService.h"
#import "MBDataHandler.h"
#import "MBConstants.h"
#import "MBDocumentOperation.h"

@interface MBDocumentAbstractTest : XCTestCase
@property (nonatomic,retain) NSData *configData;
@property (nonatomic, retain) NSData *jsonDocumentData;
@property (nonatomic,retain) NSData *xmlDocumentData;
@property (nonatomic,retain) MBConfigurationDefinition *config;


@end