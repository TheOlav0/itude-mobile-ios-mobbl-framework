//
//  MBViewBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBBuildState;

@protocol MBViewBinder <NSObject>

- (UIView *)bindView:(MBBuildState *)state;

@end
