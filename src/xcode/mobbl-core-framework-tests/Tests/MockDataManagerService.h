//
//  MockDataManagerService.h
//  mobbl-core-framework
//
//  Created by Olaf on 13/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mobbl_core_framework.h"

@interface MockDataManagerService : MBDataManagerService
-(void) registerDataHandler;
-(void) registerDataHandler:(id<MBDataHandler>)handler withName:(NSString *)name;
+(MBDataManagerService*) sharedInstance;
-(MBDocument *) createDocument:(NSString *)documentName;
-(MBDocument*) loadDocument:(NSString *)documentName;
-(MBDocument*) loadDocument:(NSString *)documentName withArguments:(MBDocument *)args;
-(MBDocument*) loadFreshDocument:(NSString *)documentName;
-(MBDocument*) loadFreshDocument:(NSString *)documentName withArguments:(MBDocument *)args;

@end