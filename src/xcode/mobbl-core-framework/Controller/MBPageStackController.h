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

#import "MBPageStackDefinition.h"
#import "MBPage.h"
#import "MBNotificationTypes.h"

@class MBDialogController;
@class MBBasicViewController;

@interface MBPageStackController : NSObject <UINavigationControllerDelegate>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) MBDialogController *dialogController;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, assign) CGRect bounds;

- (id) initWithDefinition:(MBPageStackDefinition *)definition withDialogController:(MBDialogController *)parent;
//- (id) initWithDefinition:(MBPageStackDefinition *)definition page:(MBPage*) page bounds:(CGRect) bounds;

- (void) showViewController:(MBBasicViewController*) page displayMode:(NSString*) displayMode transitionStyle:(NSString *) style;
- (void) popPageWithTransitionStyle:(NSString *)transitionStyle animated:(BOOL) animated;


- (UIView*) view;
- (CGRect) screenBoundsForDisplayMode:(NSString*) displayMode;

- (void) showActivityIndicator;
- (void) hideActivityIndicator;

- (void) willActivate;
- (void) didActivate;

- (NSString *)dialogName;

- (void) resetView;

@end
