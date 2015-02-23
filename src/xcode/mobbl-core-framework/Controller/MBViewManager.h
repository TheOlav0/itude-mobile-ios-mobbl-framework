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

#import "MBTypes.h"
#import "MBDialogManager.h"
#import "MBContentViewWrapper.h"

@class MBPage;
@class MBAlert;
@class MBBasicViewController;

@interface MBViewManager : NSObject<UITabBarControllerDelegate, UINavigationControllerDelegate, MBDialogManagerDelegate>
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) MBDialogManager *dialogManager;
@property (nonatomic, retain) UIAlertView *currentAlert;
@property (nonatomic, retain) id<MBContentViewWrapper> contentViewWrapper;

- (id) init;
- (void)showViewController:(MBBasicViewController*)viewController displayMode:(NSString*)displayMode;
- (void)showViewController:(MBBasicViewController *)viewController displayMode:(NSString*)displayMode transitionStyle:(NSString *)style;
- (void) showAlert:(MBAlert *) alert;

/**
 * Managing the view of the viewManager
 */
- (void) resetView;
- (void) resetViewPreservingCurrentPageStack;
- (void) makeKeyAndVisible;

/**
 * Used to present and dismiss a (modal) viewController
 */
- (void) presentViewController:(UIViewController *)controller fromViewController:(UIViewController *)fromViewController animated:(BOOL)animated;
- (void) presentViewController:(UIViewController *)controller fromViewController:(UIViewController *)fromViewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void) dismisViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void) dismisViewController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 * Managing the activity indicator
 */
- (void) showActivityIndicator;
- (void) showActivityIndicatorWithMessage:(NSString*) message;
- (void) showActivityIndicatorOnDialog:(MBDialogController *)dialogController;
- (void) showActivityIndicatorOnDialog:(MBDialogController *)dialogController withMessage:(NSString*) message;

- (void) hideActivityIndicator;
- (void) hideActivityIndicatorOnDialog:(MBDialogController *)dialogController;

/**
 * Returns the bounds of the UIWindow
 */
- (CGRect) bounds;

/**
 * Returns the top most visibile viewController. In most cases this will be the rootViewController of the UIWindow or the modalViewController of the UIWindow.
 */
- (UIViewController *)topMostVisibleViewController;

/**
 * Other methods
 */
- (MBViewState) currentViewState; // TODO: Refacor the viewState away

@end
