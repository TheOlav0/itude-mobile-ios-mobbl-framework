//
//  MBComponent+ViewBinding.h
//  kitchensink-app
//
//  Created by Emiel Bon on 20-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBComponentContainer.h"

@interface MBComponentContainer (ViewBinding)

- (MBComponent *)childWithName:(NSString *)name;
- (NSArray *)childrenWithName:(NSString *)name;

@end
