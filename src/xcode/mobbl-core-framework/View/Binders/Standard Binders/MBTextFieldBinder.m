//
//  MBTextFieldBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 16-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBTextFieldBinder.h"
#import "MBField.h"

@implementation MBTextFieldBinder

+ (instancetype)binderWithIdentifier:(NSString *)identifier
{
    return [[[MBTextFieldBinder alloc] initWithBindingIdentifier:identifier] autorelease];
}

- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component
{
    assert([view isKindOfClass:[UITextField class]]);
    
    UITextField *textField = (UITextField *)view;
    MBField *field = (MBField *)component;
    textField.text        = field.formattedValue;
    textField.placeholder = field.hint;
    textField.delegate    = field;
    [textField addTarget:field
                  action:@selector(textFieldDoneEditing:)
        forControlEvents:UIControlEventEditingChanged | UIControlEventEditingDidEnd | UIControlEventEditingDidEndOnExit];
}

@end
