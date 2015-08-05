//
//  TestElementContainer.m
//  mobbl-core-framework
//
//  Created by Olaf on 14/07/15.
//  Copyright (c) 2015 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import "TestElementContainer.h"
@implementation TestElementContainer

-(id) valueForPath:(NSString *)path
{
    if([@"index" isEqual:path])
        return @"1";
    else if([@"blerp[1]" isEqual:path])
             return @"whoop";
             else if([@"whoop[1]" isEqual:path])
             return @"Heuy!";
    else return @"MERP!";
}
@end
