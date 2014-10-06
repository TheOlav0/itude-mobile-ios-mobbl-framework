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
//  MBDatePickerPopoverController.m
//  mobbl-core-framework
//
//  Created by Frank van Eenbergen on 08/11/13.
//

#import "MBDatePickerPopoverController.h"

#define C_PICKER_HEIGHT 216
#define C_BAR_HEIGHT 44

@implementation MBDatePickerPopoverController

@synthesize popover = _popover;

- (void)dealloc
{
    [_popover release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self forcePopoverSize];
}

- (void)removeFromSuperviewWithAnimation {
    if (self.popover){
        [self.popover dismissPopoverAnimated:YES];
    }
}

#pragma mark -
#pragma mark Util

- (void) sizeToFit {
    CGFloat height = C_PICKER_HEIGHT + C_BAR_HEIGHT;
    
    CGRect frame = self.view.frame;
    frame.size.height = height;
    self.view.frame = frame;
    
    self.contentSizeForViewInPopover = CGSizeMake(320, height);
}

// Make sure that the popover resizes
- (void) forcePopoverSize {
    CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
    CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
    self.contentSizeForViewInPopover = fakeMomentarySize;
    self.contentSizeForViewInPopover = currentSetSizeForPopover;
}

@end
