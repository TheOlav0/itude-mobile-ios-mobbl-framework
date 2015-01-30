//
//  MBButtonBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 19-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBButtonBinder.h"
#import "MBSimpleTextBinder.h"
#import "MBComponent.h"
#import "MBField.h"

@implementation MBButtonBinder

+ (instancetype)binderWithIdentifier:(NSString *)identifier
{
    return [[[MBButtonBinder alloc] initWithBindingIdentifier:identifier] autorelease];
}

- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component
{
    assert([component isKindOfClass:[MBField class]]);
    assert([view      isKindOfClass:[UIButton class]]);
    
    UIButton *button = (UIButton *)view;
    MBField  *field  = (MBField *)component;

    [button setTitle:field.value forState:UIControlStateNormal];
    
    if (field.outcomeName) {
        [(id)view addTarget:field action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
