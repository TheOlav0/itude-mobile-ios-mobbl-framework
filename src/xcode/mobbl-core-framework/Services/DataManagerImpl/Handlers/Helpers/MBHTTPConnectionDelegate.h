//
//  MBHTTPConnectionDelegate.h
//  mobbl-core-framework
//
//  Created by Sven Meyer on 16/07/14.
//  Copyright (c) 2014 Itude Mobile B.V., The Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBHTTPConnection;


@protocol MBHTTPConnectionDelegate <NSObject>


@property BOOL finished;
@property (nonatomic, retain) id<MBHTTPConnection> connection;
@property (nonatomic, retain) NSError *err;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSMutableData *data;


@end
