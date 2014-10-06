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

//
//  MBDialogManager.h
//  mobbl-core-framework
//
//  Created by Frank van Eenbergen on 9/25/13.
//

#import <Foundation/Foundation.h>
#import "MBOrderedMutableDictionary.h"

@class MBDialogController;
@class MBPageStackController;


@protocol MBDialogManagerDelegate <NSObject>
@required
- (void)didLoadDialogControllers:(NSArray *)dialogControllers;
- (void)didEndPageStackWithName:(NSString*) pageStackName;
- (void)didActivatePageStack:(MBPageStackController*) pageStackController inDialog:(MBDialogController *)dialogController;
@end


@interface MBDialogManager : NSObject
@property (nonatomic, assign) id<MBDialogManagerDelegate>delegate;
@property (nonatomic, retain) MBOrderedMutableDictionary *dialogControllers;
@property (nonatomic, retain, readonly) NSString *activePageStackName;
@property (nonatomic, retain, readonly) NSString *activeDialogName;

- (id)initWithDelegate:(id<MBDialogManagerDelegate>) delegate;

/**
 * @name Gettings Dialogs and PageStacks
 */
- (MBDialogController *)dialogWithName:(NSString*) name;
- (MBDialogController *)dialogForPageStackName:(NSString *)name;
- (MBPageStackController *)pageStackControllerWithName:(NSString*) name;


/**
 * @name Managing PageStacks
 */
- (void) popPageOnPageStackWithName:(NSString*) pageStackName;
- (void) endPageStackWithName:(NSString*) pageStackName keepPosition:(BOOL) keepPosition;
- (void) activatePageStackWithName:(NSString*) pageStackName;
- (void) activateDialogWithName:(NSString*) dialogName;

@end
