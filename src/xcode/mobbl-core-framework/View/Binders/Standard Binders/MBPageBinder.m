//
//  MBPageBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBPageBinder.h"
#import "MBBuildState.h"
#import "MBBasicViewController.h"
#import "MBPage.h"

@interface MBPageBinder()

@property (nonatomic, retain) MBBuildState *state;
@property (nonatomic, retain) NSMutableDictionary *childViewBinders;

@end

@implementation MBPageBinder

- (MBBuildState *)state
{
    if (!_state) {
        _state = [[MBBuildState alloc] init];
    }
    return _state;
}

- (NSMutableDictionary *)childViewBinders
{
    if (!_childViewBinders) {
        _childViewBinders = [[NSMutableDictionary alloc] init];
    }
    return _childViewBinders;
}

- (instancetype)initWithViewController:(MBBasicViewController *)viewController
{
    self = [super initWithBindingIdentifier:nil];
    if (self) {
        self.state.mainViewBinder = self;
        self.state.view           = viewController.view;
        self.state.component      = viewController.page;
        self.state.element        = viewController.page.document;
        self.state.document       = viewController.page.document;
    }
    return self;
}

+ (instancetype)binderWithViewController:(MBBasicViewController *)viewController
{
    return [[[MBPageBinder alloc] initWithViewController:viewController] autorelease];
}

- (void)bind
{
    [self bindView:self.state];
}

- (UIView *)findSpecificView:(MBBuildState *)state
{
    id<MBViewBinder> binder = self.childViewBinders[state.component.name];
    return [binder bindView:state];
}

- (void)registerBinder:(id<MBViewBinder>)binder
{
    assert([binder respondsToSelector:@selector(identifier)]);
    self.childViewBinders[[(id)binder identifier]] = binder;
}

- (void)dealloc
{
    self.state = nil;
    self.childViewBinders = nil;
    [super dealloc];
}

@end
