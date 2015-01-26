//
//  MBTextBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBSimpleTextBinder.h"
#import "MBField.h"

@implementation MBSimpleTextBinder

+ (instancetype)binderWithIdentifier:(NSString *)identifier
{
    return [[[MBSimpleTextBinder alloc] initWithBindingIdentifier:identifier] autorelease];
}

- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component
{
    // Can be a UITextView, UITextField or UILabel, anything that responds to setText
    assert([component isKindOfClass:[MBField class]]);
    assert([view respondsToSelector:@selector(setText:)]);
    
    MBField *field = (MBField *)component;
    [(id)view setText:field.formattedValue];
}

@end
