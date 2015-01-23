//
//  MBPageBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBBaseViewBinder.h"
#import "MBViewBinder.h"

@class MBBasicViewController;

@interface MBPageBinder : MBBaseViewBinder

- (instancetype)initWithViewController:(MBBasicViewController *)viewController;
+ (instancetype)binderWithViewController:(MBBasicViewController *)viewController;

- (void)registerBinder:(id<MBViewBinder>)binder;
- (void)bind;

@end
