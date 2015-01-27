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

//  Wraps a UIViewController

#import "MBApplicationFactory.h"
#import "MBComponent.h"
#import "MBPanel.h"
#import "MBViewControllerProtocol.h"
#import "MBDocumentDiff.h"
#import "MBPageDefinition.h"
#import "MBOutcomeListenerProtocol.h"
#import "MBTypes.h"

#import "UIViewController+Rotation.h"

@class MBApplicationController;
@class MBApplicationFactory;

/** Main unit of navigation within the application. Associated with exactly one UIViewController subclass. You never need to subclass an MBPage */
@interface MBPage : MBPanel

@property (nonatomic, retain) NSString *pageName;
@property (nonatomic, retain) NSString *rootPath;
@property (nonatomic, retain) NSString *pageStackName;
@property (nonatomic, retain) NSString *dialogName;
@property (nonatomic, retain) MBDocument *document;
@property (nonatomic, assign) MBApplicationController *applicationController;
@property (nonatomic, assign) UIViewController <MBViewControllerProtocol>*viewController;
@property (nonatomic, retain) NSMutableArray *childViewControllers; // Contains the ViewControllers of potential child views (like UITableViewControllers)
@property (nonatomic, retain) MBDocumentDiff *documentDiff;
@property (nonatomic, assign) MBPageType pageType;
@property (nonatomic, retain) NSString *transitionStyle;

@property (nonatomic, assign) CGRect maxBounds;
@property (nonatomic, assign) MBViewState viewState;

// for loading interface builder files:
- (instancetype)initWithDefinition:(MBPageDefinition*) definition
                withViewController:(UIViewController<MBViewControllerProtocol>*) viewController
                          document:(MBDocument*) document
                          rootPath:(NSString*) rootPath
                         viewState:(MBViewState) viewState;

// for initialising a generic page:
- (instancetype)initWithDefinition:(id)definition
                          document:(MBDocument*) document
                          rootPath:(NSString*) rootPath
                         viewState:(MBViewState) viewState
                     withMaxBounds:(CGRect) bounds;

// Outcome handling
- (void)handleOutcome:(NSString *)outcomeName;
- (void)handleOutcome:(NSString *)outcomeName withPathArgument:(NSString*) path;
- (void)handleException:(NSException *)exception;

// View
- (UIView*)view;
- (void)rebuild;
- (MBViewState)currentViewState;
- (void)unregisterAllViewControllers;
- (id)viewControllerOfType:(Class) clazz;
- (void)hideKeyboard:(id)sender;

- (MBDocumentDiff*)diffDocument:(MBDocument*)other;

@end
