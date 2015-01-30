//
//  MBTableViewBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBBaseViewBinder.h"

@interface MBSimpleTableViewBinder : MBBaseViewBinder <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) MBBuildState   *state;
@property (nonatomic, retain) NSMutableArray *components;
@property (nonatomic, retain) UINib          *cellNib;

- (instancetype)initWithBindingIdentifier:(NSString *)identifier cellNib:(UINib *)cellNib;
+ (instancetype)binderWithIdentifier:(NSString *)identifier cellNib:(UINib *)cellNib;
- (UITableViewCell *)reusableCellForTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareCellForBinding:(UITableViewCell *)cell;

@end
