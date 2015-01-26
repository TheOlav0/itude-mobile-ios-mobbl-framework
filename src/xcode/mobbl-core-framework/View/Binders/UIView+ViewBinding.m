//
//  UIView+ViewBinding.m
//  kitchensink-app
//
//  Created by Emiel Bon on 16-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "UIView+ViewBinding.h"
#import "MBCategoryProperties.h"

@implementation UIView (ViewBinding)

JESynthesize(retain, NSString *, bindingIdentifier, setBindingIdentifier);

- (UIView *)viewWithBindingIdentifier:(NSString *)identifier
{
    // Check own identifier
    if ([self.bindingIdentifier isEqualToString:identifier]) {
        return self;
    }
    // Check subviews
    return [self subviewWithBindingIdentifier:identifier];
}

- (UIView *)subviewWithBindingIdentifier:(NSString *)identifier
{
    // Check subview's identifiers
    for (UIView *subview in self.subviews) {
        if ([subview.bindingIdentifier isEqualToString:identifier]) {
            return subview;
        }
    }
    // Recursively check subviews
    for (UIView *subview in self.subviews) {
        UIView *match = [subview viewWithBindingIdentifier:identifier];
        if (match) {
            return match;
        }
    }
    return nil;
}

@end
