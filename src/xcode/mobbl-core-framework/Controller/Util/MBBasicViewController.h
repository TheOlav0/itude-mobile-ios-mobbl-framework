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

#import "MBViewControllerProtocol.h"

@class MBPage;
@class MBPageStackController;
@protocol MBOutcomeListenerProtocol;

// This class is the ROOT of the MEMORY ALLOCATION STRUCTURE; the root of all retains.
// This class is pushed on UINavigationControllers or other controllers; when released it should trigger
// the release of MBPage, MBDocument and any other page related stuff.

/** Template for custom MBViewController classes. Coupled to exactly one MBPage */
@interface MBBasicViewController : UIViewController<MBViewControllerProtocol> 

@property (nonatomic, retain) MBPage *page;
@property (nonatomic, retain) MBPageStackController *pageStackController;

/** looks up the MBPage associated with this instance and sets the view property with a fresh view hierarchy constructed from the page definition */
- (void)rebuildView;
- (void)handleException:(NSException *) exception;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (void)registerOutcomeListener:(id<MBOutcomeListenerProtocol>) listener;
- (void)unregisterOutcomeListener:(id<MBOutcomeListenerProtocol>) listener;

@end
