//
//  MBTableViewBinder.m
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import "MBSimpleTableViewBinder.h"
#import "MBBuildState.h"
#import "UIView+ViewBinding.h"
#import "MBComponent.h"
#import "MBPanel.h"

@implementation MBSimpleTableViewBinder

- (instancetype)initWithBindingIdentifier:(NSString *)identifier cellNib:(UINib *)cellNib
{
    self = [super initWithBindingIdentifier:identifier];
    if (self) {
        self.cellNib = cellNib;
    }
    return self;
}

+ (instancetype)binderWithIdentifier:(NSString *)identifier cellNib:(UINib *)cellNib
{
    return [[[MBSimpleTableViewBinder alloc] initWithBindingIdentifier:identifier cellNib:cellNib] autorelease];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Used to prevent the MOBBL "feature" of calling this method on anything called "delegate"
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Used to prevent the MOBBL "feature" of calling this method on anything called "delegate"
}

- (UIView *)bindView:(MBBuildState *)state
{
    self.state = [[state copy] autorelease];
    
    UIView *view = [self findSpecificView:state];
    
    if (view) {
        [self populateView:view withDataFromComponent:state.component];
    }
    
    return view;
}

- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component
{
    assert([view isKindOfClass:[UITableView class]]);
    
    self.components = [component childrenOfKind:[MBComponent class]];
    
    UITableView *tableView = (UITableView *)view;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView reloadData];
}

- (UITableViewCell *)reusableCellForTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier
{
    [tableView registerNib:self.cellNib forCellReuseIdentifier:reuseIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    return cell;
}

- (void)prepareCellForBinding:(UITableViewCell *)cell
{
    // Default empty implementation
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.components.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBBuildState *state = [[self.state copy] autorelease];
    state.component = self.components[indexPath.row];
    state.element   = [state.document valueForPath:state.component.absoluteDataPath];
 
    NSString *reuseIdentifier = state.component.name;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [self reusableCellForTableView:tableView reuseIdentifier:reuseIdentifier];
    }
    
    state.view = cell;
    [self prepareCellForBinding:cell];
    [state.mainViewBinder bindView:state];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MBComponent *component = self.components[indexPath.row];
    assert([component isKindOfClass:[MBPanel class]]);
    MBPanel *panel = (MBPanel *)component;
    [panel handleOutcome:panel.outcomeName withPathArgument:panel.absoluteDataPath];
}

#pragma mark - Misc

- (void)dealloc
{
    self.state = nil;
    self.components = nil;
    self.cellNib = nil;
    [super dealloc];
}

@end
