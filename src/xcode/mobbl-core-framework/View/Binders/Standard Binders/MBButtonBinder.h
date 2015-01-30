//
//  MBButtonBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 19-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBBaseViewBinder.h"
#import "MBSimpleTextBinder.h"

@interface MBButtonBinder : MBSimpleTextBinder

+ (instancetype)binderWithIdentifier:(NSString *)identifier;
- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component;

@end
