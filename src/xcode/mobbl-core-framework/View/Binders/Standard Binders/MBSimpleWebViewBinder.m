//
//  MBWebViewBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 21-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBSimpleWebViewBinder.h"
#import "MBField.h"

@implementation MBSimpleWebViewBinder

+ (instancetype)binderWithIdentifier:(NSString *)identifier
{
    return [[[MBSimpleWebViewBinder alloc] initWithBindingIdentifier:identifier] autorelease];
}

- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component
{
    assert([view isKindOfClass:[UIWebView class]]);
    
    UIWebView *webView = (UIWebView *)view;
    MBField *field = (MBField *)component;
    
    [webView loadHTMLString:field.formattedValue baseURL:nil];
}

@end
