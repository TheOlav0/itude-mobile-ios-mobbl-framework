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

#import "MBViewManager.h"
#import "MBApplicationController.h"
#import "MBPageDefinition.h"
#import "MBAlertDefinition.h"
#import "MBDialogDefinition.h"
#import "MBAction.h"
#import "MBResultListener.h"
#import "MBTransitionStyleFactory.h"
#import "MBContentViewWrapper.h"

@class MBApplicationController;
@class MBPage;
@class MBAlert;
@class MBOutcome;
@class MBDocument;
@class MBDialogController;

@protocol MBViewControllerProtocol;

/** Factory class for creating custom UIViewControllers, MBResultListeners and MBActions 
 * In short there are three steps to using custom code with MOBBL framework:

 1. Create Pages, Actions and ResultListeners in the application definition files  (config.xmlx and endpoints.xmlx).
 2. Create a subclass of the MBApplicationFactory which can create custom UIViewControllers, MBActions and MBResultListeners,
 3. set the sharedInstance to your MBApplicationFactory subclass:
 
     CustomApplicationFactory *applicationFactory = [[[CustomApplicationFactory alloc] init] autorelease];
     [MBApplicationFactory setSharedInstance:applicationFactory];

*/
@interface MBApplicationFactory :  NSObject 

@property (nonatomic, retain) MBTransitionStyleFactory *transitionStyleFactory;

/** the shared instance */
+(MBApplicationFactory *) sharedInstance;
+(void) setSharedInstance:(MBApplicationFactory *) factory;

/**
 *  Given a page name, this returns the corresponding view controller instance.
 *
 *  The default implementation for this method returns nil. It should be overwritten by subclass (i.e. a custom ApplicationFactory). After this method is called, the MBPage gets bound to the instance.
 *
 *  @param pageName The name of the page
 *
 *  @return A view controller instance
 */
- (UIViewController <MBViewControllerProtocol>*)viewControllerForPageWithName:(NSString *)pageName;

-(MBAlert *)createAlert:(MBAlertDefinition *)definition
               document:(MBDocument *) document
               rootPath:(NSString *)rootPath
               delegate:(id<UIAlertViewDelegate>)alertViewDelegate;
/** override to create MBAction conforming custom actions */
-(id<MBAction>) createAction:(NSString *)actionClassName;
-(MBDialogController *)createDialogController:(MBDialogDefinition *)definition;
/** override to create custom MBResultListeners */
-(id<MBResultListener>) createResultListener:(NSString *)listenerClassName;
-(id<MBContentViewWrapper>) createContentViewWrapper;

/** override this class to create MBPages, UIViewControllers and bind the two together */
-(MBPage *) createPage:(MBPageDefinition *)definition
              document:(MBDocument*) document
              rootPath:(NSString*) rootPath
             viewState:(MBViewState) viewState
         withMaxBounds:(CGRect) bounds __deprecated_msg("use viewControllerForPageWithName: instead");
-(UIViewController *) createViewController:(MBPage*) page __deprecated_msg("only use for backwards compatibility with View Builders");

@end
