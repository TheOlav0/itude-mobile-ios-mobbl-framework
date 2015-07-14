//
//  MockDataManagerService.m
//  mobbl-core-framework
//
//  Created by Olaf on 13/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import "MockDataManagerService.h"


static MockDataManagerService *_instance = nil;


@implementation MockDataManagerService

+ (MBDataManagerService *) sharedInstance {
    @synchronized(self) {
        if(_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

-(void)registerDataHandler {
    
}

-(void)registerDataHandler:(id<MBDataHandler>)handler withName:(NSString *)name{
}

- (MBDocument *) createDocument: (NSString *) documentName {
    MBDocumentDefinition *def = [[MBDocumentDefinition alloc] init];
    [def setName:documentName];
    MBDocument *doc = [[MBDocument alloc] initWithDocumentDefinition:def];
    return doc;
    
}

- (MBDocument *) loadDocument: (NSString*) documentName {
    return [self createDocument:documentName];
}

- (MBDocument *) loadFreshDocument:(NSString *)documentName {
    return [self createDocument:documentName];
}

- (MBDocument *) loadDocument:(NSString *)documentName withArguments:(MBDocument *)args{
    return [self createDocument:documentName];
}

- (MBDocument *) loadFreshDocument:(NSString *)documentName withArguments:(MBDocument *)args{
    MBDocument *newDoc = [self createDocument:documentName];
    [newDoc setArgumentsUsed:args];
    return newDoc;
}


@end
