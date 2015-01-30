//
//  MBDefaultStyleTableViewBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 20-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBStandardStyleTableViewBinder.h"

@interface MBStandardStyleTableViewBinder ()

@property (nonatomic, retain) NSString *titleBindingIdentifier;
@property (nonatomic, retain) NSString *detailBindingIdentifier;
@property (nonatomic, assign) UITableViewCellStyle style;

@end

@implementation MBStandardStyleTableViewBinder

- (instancetype)initWithBindingIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style bindTitleTo:(NSString *)titleId bindDetailTo:(NSString *)detailId
{ 
    self = [super initWithBindingIdentifier:identifier cellNib:nil];
    if (self) {
        self.titleBindingIdentifier = titleId;
        self.detailBindingIdentifier = detailId;
        self.style = style;
    }
    return self;
}

+ (instancetype)binderWithIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style bindTitleTo:(NSString *)titleId bindDetailTo:(NSString *)detailId
{
	return [[[MBStandardStyleTableViewBinder alloc] initWithBindingIdentifier:identifier
                                                                        style:style
                                                                  bindTitleTo:titleId
                                                                 bindDetailTo:detailId] autorelease];
}

- (void)prepareCellForBinding:(UITableViewCell *)cell
{
    cell.textLabel.bindingIdentifier = self.titleBindingIdentifier;
    cell.detailTextLabel.bindingIdentifier = self.detailBindingIdentifier;
}

- (UITableViewCell *)reusableCellForTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier
{
    return [[[UITableViewCell alloc] initWithStyle:self.style reuseIdentifier:reuseIdentifier] autorelease];
}

- (void)dealloc
{
    self.titleBindingIdentifier = nil;
    self.detailBindingIdentifier = nil;
    [super dealloc];
}

@end
