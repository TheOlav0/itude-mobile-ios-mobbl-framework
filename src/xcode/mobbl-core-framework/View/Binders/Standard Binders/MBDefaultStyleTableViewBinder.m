//
//  MBDefaultStyleTableViewBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 21-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBDefaultStyleTableViewBinder.h"

@implementation MBDefaultStyleTableViewBinder

- (instancetype)initWithBindingIdentifier:(NSString *)identifier bindTitleTo:(NSString *)titleId
{
    return [super initWithBindingIdentifier:identifier style:UITableViewCellStyleDefault bindTitleTo:titleId bindDetailTo:nil];
}

+ (instancetype)binderWithIdentifier:(NSString *)identifier bindTitleTo:(NSString *)titleId
{
    return [[[MBDefaultStyleTableViewBinder alloc] initWithBindingIdentifier:identifier bindTitleTo:titleId] autorelease];
}

@end
