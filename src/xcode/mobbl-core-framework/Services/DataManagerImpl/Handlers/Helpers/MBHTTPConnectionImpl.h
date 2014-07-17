//
//  MBHTTPConnectionImpl.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 16/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBHTTPConnection.h"

@interface MBHTTPConnectionImpl : NSObject <MBHTTPConnection>

- initWithRequest:(NSURLRequest *)request delegate:(id<MBHTTPConnectionDelegate>)delegate;

@end
