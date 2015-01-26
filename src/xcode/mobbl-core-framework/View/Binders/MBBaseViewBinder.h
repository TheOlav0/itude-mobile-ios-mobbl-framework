//
//  MBBaseViewBinder.h
//  kitchensink-app
//
//  Created by Emiel Bon on 15-01-15.
//  Copyright (c) 2015 Itude Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBViewBinder.h"
// The following 2 imports are not directly used here, but are used by all subclasses. This prevents having to include them everywhere.
#import "MBBuildState.h"
#import "UIView+ViewBinding.h"

@interface MBBaseViewBinder : NSObject <MBViewBinder>

@property (nonatomic, retain) NSString *identifier;

/**
 *  Initializes a view binder with a binding identifier and returns it to the caller
 *
 *  This is the designated initializer.
 *
 *  @param identifier A string used to identify the component and view to which this binder binds.
 *  @return An initialized MBBaseViewBinder
 */
- (instancetype)initWithBindingIdentifier:(NSString *)identifier;

/**
 *  Retrieves a view in the hierarchy by its identifier and populates it with its current MBComponent
 *
 *  This method tries to match the name of the MBComponent in state to the bindingIdentifier of state.view or it's subviews. 
 *  It then uses populateView:withDataFromComponent: to populate the view with data.
 *  After populating the view the method prepares a new state object and continues traversing the MBComponent hierarchy.
 *
 *  @param state A state object used to keep track of contextual data in the traversal
 *  @return A view where bindingIdentifier == state.component.name, or nil of there is no match
 *  @see populateView:withDataFromComponent
 */
- (UIView *)bindView:(MBBuildState *)state;

// This method may be overridden by a subclass
- (UIView *)findSpecificView:(MBBuildState *)state;

/**
 *  Populates the retrieved view with data from the component
 * 
 *  The default implementation for populateView:withDataFromComponent is empty. 
 *  Only when the populateView:withDataFromComponent: method is overridden by a subclass is it actually populated. 
 *  The view's bindingIdentifier property matches the component's name
 *
 *  @param view      The view retrieved in the bindView: method
 *  @param component The component retrieved in the bindView: method
 */
- (void)populateView:(UIView *)view withDataFromComponent:(MBComponent *)component;

@end
