//
//  UIView+ViewBinding.h
//  kitchensink-app
//
//  Created by Emiel Bon on 16-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewBinding)

@property (nonatomic, retain) NSString *bindingIdentifier;

- (UIView *)viewWithBindingIdentifier:(NSString *)identifier;
- (UIView *)subviewWithBindingIdentifier:(NSString *)identifier;

@end
