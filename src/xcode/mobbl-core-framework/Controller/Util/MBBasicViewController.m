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

#import "MBBasicViewController.h"
#import "MBPage.h"
#import "MBOrientationManager.h"
#import "MBPageStackController.h"
#import "MBDialogController.h"
#import "MBViewBuilderFactory.h"

// Adds rotation support
#import "UIViewController+Rotation.h"
#import "UIViewController+Layout.h"

@interface MBBasicViewController ()

@property (nonatomic, retain) NSMutableArray *outcomeListeners;

@end

@implementation MBBasicViewController

- (NSMutableArray *)outcomeListeners
{
    if (!_outcomeListeners) {
        _outcomeListeners = [[NSMutableArray alloc] init];
    }
    return _outcomeListeners;
}

- (void) dealloc
{
    self.page = nil;
    self.pageStackController = nil;
    self.outcomeListeners = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackButton];
    [self setupLayoutForIOS7];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
	[super didMoveToParentViewController:parent];

	if (!parent) {
        [self unregisterListenersWithOutcomeHandler];
        self.outcomeListeners = nil;
    }
}

- (void)handleException:(NSException *) exception
{
	[self.page handleException:exception];
}

- (void)rebuildView
{
    // Make sure we clear the cache of all related documents:
    [self.page rebuild];
    self.view = [self.page buildViewWithMaxBounds:self.page.maxBounds forParent:nil viewState:self.page.viewState];
    [self setupLayoutForIOS7];
}

- (void)showActivityIndicator
{
	[[MBApplicationController currentInstance] showActivityIndicator];
}

- (void)hideActivityIndicator
{
	[[MBApplicationController currentInstance] hideActivityIndicator];
}

// Setup a custom backbutton when a builder is registred
- (void)setupBackButton
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        UIViewController *previousViewController = viewControllers[viewControllers.count-2];
        UIBarButtonItem *backButton = [[MBViewBuilderFactory sharedInstance].backButtonBuilderFactory buildBackButtonWithTitle:previousViewController.navigationItem.title];
        if (backButton) {
            [self.navigationItem setLeftBarButtonItem:backButton animated:NO];
        }
    }
}

#pragma mark - View lifecycle delegate methods

- (void)viewDidAppear:(BOOL)animated
{
	for (id childView in [self.view subviews]){
		if ([childView respondsToSelector:@selector(delegate)]) {
			id delegate = [childView delegate];
            if (delegate != self && [delegate respondsToSelector:@selector(viewDidAppear:)]) {
                [delegate viewDidAppear:animated];
            }
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	// register all outcome listeners with the application controller; this view controller just became
	// visible, so it is interested in outcomes
    [self registerListenersWithOutcomeHandler];
    
	for (id childView in self.view.subviews){
		if ([childView respondsToSelector:@selector(delegate)]) {
			id delegate = [childView delegate];
            if(delegate != self && [delegate respondsToSelector:@selector(viewWillAppear:)]) {
                [delegate viewWillAppear:animated];
            }
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	for (id childView in self.view.subviews) {
		if ([childView respondsToSelector:@selector(delegate)]) {
			id delegate = [childView delegate];
			if(delegate != self){
				//if ([delegate respondsToSelector:@selector(viewDidDisappear:)]) {
				[delegate viewDidDisappear:animated];
				//}
			}
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	// remove all outcome listeners from the application controller; this view controller
	// is going to disappear, so it isn't interested in them anumore
    [self unregisterListenersWithOutcomeHandler];
    
	for (id childView in self.view.subviews){
		if ([childView respondsToSelector:@selector(delegate)]) {
			id delegate = [childView delegate];
			if(delegate != self ){//&& [delegate respondsToSelector:@selector(viewWillDisappear:)]) {
				[delegate viewWillDisappear:animated];
			}
		}
	}
}

#pragma mark - Outcome listeners

- (void)registerOutcomeListener:(id<MBOutcomeListenerProtocol>) listener {
    if (listener == (id<MBOutcomeListenerProtocol>)self) {
        NSLog (@"Don't register self as outcomeListener; this is done automatically!");
        return;
    }
    
	if (![self.outcomeListeners containsObject:listener]) {
		[self.outcomeListeners addObject:listener];
		[[MBApplicationController currentInstance].outcomeManager registerOutcomeListener:listener];
	}
}

- (void)unregisterOutcomeListener:(id<MBOutcomeListenerProtocol>) listener
{
	[[MBApplicationController currentInstance].outcomeManager unregisterOutcomeListener:listener];
	[self.outcomeListeners removeObject:listener];
}

- (void)registerListenersWithOutcomeHandler
{
    for(id<MBOutcomeListenerProtocol> lsnr in self.outcomeListeners) {
		[[MBApplicationController currentInstance].outcomeManager registerOutcomeListener:lsnr];
	}
    
    if ([self conformsToProtocol:@protocol(MBOutcomeListenerProtocol) ]) {
        [[MBApplicationController currentInstance].outcomeManager registerOutcomeListener:(id<MBOutcomeListenerProtocol>)self];
    }
}

- (void)unregisterListenersWithOutcomeHandler {
    for(id<MBOutcomeListenerProtocol> lsnr in self.outcomeListeners) {
		[[MBApplicationController currentInstance].outcomeManager unregisterOutcomeListener:lsnr];
	}
    
    if ([self conformsToProtocol:@protocol(MBOutcomeListenerProtocol) ]) {
        [[MBApplicationController currentInstance].outcomeManager unregisterOutcomeListener:(id<MBOutcomeListenerProtocol>)self];
    }
}

@end
