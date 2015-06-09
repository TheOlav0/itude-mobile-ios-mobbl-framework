//
//  MBBaseViewBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBBaseViewBinder.h"
#import "MBBuildState.h"
#import "MBComponent.h"

@implementation MBBaseViewBinder

- (instancetype)initWithBindingIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}

- (UIView *)bindView:(MBBuildState *)state
{
    UIView *view = [self findSpecificView:state];
    
    if (view) {
        //[state.component attachView:view]; exists in MOBBL Android but not in iOS?
        [self populateView:view withDataFromComponent:state.component];
    }
    
    for (MBComponent *child in [state.component childrenOfKind:[MBComponent class]]) {
        MBBuildState *childState = [state copy];
        childState.component = child;
        id element = [child.document valueForPath:child.absoluteDataPath];
        childState.element = [element isKindOfClass:[MBElement class]] ? element : nil;
        childState.view = (view) ? view : childState.view;
        [childState.mainViewBinder bindView:childState];
        [childState release];
    }
    
    return view;
}

- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component
{
    // Default empty implementation
}

- (UIView *)findSpecificView:(MBBuildState *)state
{
    return [state.view viewWithBindingIdentifier:self.identifier];
}

- (void)dealloc
{
    self.identifier = nil;
    [super dealloc];
}

@end
