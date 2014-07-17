//
//  MBHTTPConnection.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 16/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBHTTPConnectionDelegate.h"

@protocol MBHTTPConnection <NSObject>

@property (nonatomic, readonly) id<MBHTTPConnectionDelegate> delegate;

- (NSURLRequest *)originalRequest;
- (NSURLRequest *)currentRequest;

- (void)cancel;

@end
