//
//  MBDefaultStyleTableViewBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 21-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBStandardStyleTableViewBinder.h"

@interface MBDefaultStyleTableViewBinder : MBStandardStyleTableViewBinder

- (instancetype)initWithBindingIdentifier:(NSString *)identifier bindTitleTo:(NSString *)titleId;
+ (instancetype)binderWithIdentifier:(NSString *)identifier bindTitleTo:(NSString *)titleId;

@end
