//
//  MBBuildState.m
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBBuildState.h"

@implementation MBBuildState

- (id)copyWithZone:(NSZone *)zone
{
    // No autorelease according to Apple conventions of copying, same as with alloc or new
    MBBuildState *other = [[MBBuildState alloc] init];
    other.mainViewBinder = self.mainViewBinder;
    other.view           = self.view;
    other.document       = self.document;
    other.element        = self.element;
    other.component      = self.component;
    return other;
}

- (void)dealloc
{
    self.mainViewBinder = nil;
    self.view = nil;
    self.document = nil;
    self.element = nil;
    self.component = nil;
    [super dealloc];
}

@end