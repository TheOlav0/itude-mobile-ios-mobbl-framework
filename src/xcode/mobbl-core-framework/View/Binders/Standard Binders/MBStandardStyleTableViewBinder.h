//
//  MBDefaultStyleTableViewBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 20-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBSimpleTableViewBinder.h"

@interface MBStandardStyleTableViewBinder : MBSimpleTableViewBinder

- (instancetype)initWithBindingIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style bindTitleTo:(NSString *)titleId bindDetailTo:(NSString *)detailId;
+ (instancetype)binderWithIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style bindTitleTo:(NSString *)titleId bindDetailTo:(NSString *)detailId;

@end
