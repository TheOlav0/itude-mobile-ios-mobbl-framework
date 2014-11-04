/*
 * (C) Copyright Itude Mobile B.V., The Netherlands.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "MBComponent.h"
#import "MBValueChangeListenerProtocol.h"

@interface MBComponent () {
    MBDocument *_document;
	NSMutableDictionary *_customAttributes;
}

@end

@implementation MBComponent

@synthesize definition = _definition;
@synthesize parent = _parent;
@synthesize style = _style;
@synthesize markedForDestruction = _markedForDestruction;
@synthesize leftInset = _leftInset;
@synthesize rightInset = _rightInset;
@synthesize topInset = _topInset;
@synthesize bottomInset = _bottomInset;
@synthesize document = _document;

-(id) initWithDefinition:(id)definition document:(MBDocument*) document parent:(MBComponentContainer *) parent {

	self = [super init];
	if (self != nil) {
		self.definition = definition;
		self.parent = parent;
        self.document = document;
        
        // Not all definitions have a style attribute; if they do set it
		if([definition respondsToSelector:@selector(style)]) {
			 self.style = [definition performSelector: @selector(style)];
		}
		_viewData = nil;
	}
	return self;
}

- (void) dealloc
{
	[_style release];
	[_viewData release];
	[_customAttributes release];
	[super dealloc];
}

- (void) buildViewStructure {
  // No children so nothing to build here    
}

-(UIView*) buildViewWithMaxBounds:(CGRect) bounds forParent:(UIView*) parent viewState:(MBViewState) viewState {
	return nil;	
}

-(void) handleOutcome:(MBOutcome *)outcomeName {
	[_parent handleOutcome:outcomeName];
}

-(void) handleOutcome:(NSString *)outcomeName withPathArgument:(NSString*) path {
	[_parent handleOutcome:outcomeName withPathArgument: path];
}

-(NSString *) componentDataPath {
  return @"";
}

-(NSString*) evaluateExpression:(NSString*) variableName {
		
	return [[self parent] evaluateExpression: variableName];
}

-(NSString*) substituteExpressions:(NSString*) expression {

	if(expression == nil) return nil;
	
	if([expression rangeOfString:@"{"].length == 0) return expression;
	
	NSScanner *scanner = [NSScanner scannerWithString:expression];
	NSString *subPart = @"";
	NSString *singleExpression;
	NSMutableString *result = [NSMutableString stringWithString:@""];
	
	BOOL evalToNil = FALSE;
	while([scanner scanUpToString:@"${" intoString:&subPart] || ![scanner isAtEnd]) {
		[result appendString:subPart];
		[scanner scanString:@"${" intoString:&subPart];
		BOOL hasExpression = [scanner scanUpToString:@"}" intoString:&singleExpression];
		if(hasExpression) {
			[scanner scanString:@"}" intoString:&subPart];
			NSString *value = [self evaluateExpression: singleExpression];
			if(value != nil) [result appendString:value];
			else evalToNil = TRUE;
		}
		subPart = @"";
	}
	[result appendString:subPart];
	if([result length] == 0 && evalToNil) result = nil;
	return result;	
}

-(NSString *) absoluteDataPath {
	
	NSString *componentPath = [self componentDataPath];
	
	// If the path is not set (a field without a path pecified for instance) return nil; since it then also does not have an absolute path:
    if(componentPath == nil) return nil;
	
	// Absolute path set for the component? (possibly using a doc:path expression) Than do not prefix with the parent path and return it:
	if([componentPath hasPrefix:@"/"] || [componentPath rangeOfString:@":"].length>0) return componentPath;
	
	NSString *pathToMe = [_parent absoluteDataPath];
	if(pathToMe != nil && ![pathToMe hasSuffix:@"/"]) pathToMe = [NSString stringWithFormat:@"%@/", pathToMe];
	if(pathToMe == nil) pathToMe = @"";
	
	if(componentPath != nil) pathToMe = [NSString stringWithFormat:@"%@%@", pathToMe, componentPath];
	return pathToMe;
}

// Returns a path that has indexed expressions evaluated (translated) i.e. something like myelement[someattr='xx'] -> myelement[12]
// for the current document; where the 12th element is matched
-(NSString *) evaluatedDataPath {
	NSString *path = [self absoluteDataPath];
	if(path != nil && [path length] > 0 && [path rangeOfString:@"="].length>0) {
		// Now translate the index expressions like [someAttr=='x' and someOther=='y'] into [idx]
		// We can only do this if the row that matches the expression does exist!
		NSMutableArray *components = [[NSMutableArray new] autorelease];
		NSString *value = [[self document] valueForPath:path translatedPathComponents:components];
		
		// Now glue together the components to make a full path again:
		NSMutableString *result = [[NSMutableString new] autorelease];
		for(NSString *part in components) {
			if(![part hasSuffix:@":"]) [result appendString:@"/"];
			[result appendFormat:@"%@", part];
		}
		if(value != nil) return result;
	}
	return path;
}


-(MBPage*) page {
	return [[self parent] page];
}

-(MBDocument*) document {
    // TODO: See if still nessesary. This document of page was always returned (even if nil) but some components have no page (like MBFields in an MBAlert) Therefor created a ivar.
    if ([[self page] document]) {
        return [[self page] document];
    }

    return _document;
}

-(BOOL) resignFirstResponder {
// override in subclasses	
	return FALSE;
}

-(BOOL) resignFirstResponder:(UIView*) view {
	BOOL result = [view resignFirstResponder];
	if([view subviews]) for(UIView* child in [view subviews]) result |= [self resignFirstResponder:child];
	return result;
}

-(void) setViewData:(id) value forKey:(NSString*) key {
	@synchronized(self) {
		if(_viewData == nil) _viewData = [[NSMutableDictionary alloc] init];	
	}
	[_viewData setValue:value forKey:key];
}

-(id) viewDataForKey:(NSString*) key {
	id result = nil;
	@synchronized(self) {
		result = [_viewData valueForKey:key];
	}
	return result;
}

-(void) setupKeyboardHiding:(UIView*) view {
	UIButton *keyboardHidingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	keyboardHidingButton.frame = [UIScreen mainScreen].applicationFrame;
	[keyboardHidingButton addTarget:[self page] action:@selector(hideKeyboard:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:keyboardHidingButton];
	[view sendSubviewToBack:keyboardHidingButton];
}

-(NSString*) attributeAsXml:(NSString*)name withValue:(id) attrValue {
	return attrValue == nil?@"": [NSString stringWithFormat:@" %@='%@'", name, attrValue];
}

-(NSString*) booleanAsXml:(NSString*)name withValue:(BOOL) attrValue {
    return [NSString stringWithFormat:@" %@='%@'", name, attrValue?@"TRUE":@"FALSE"];
}

- (NSString *) asXmlWithLevel:(int)level {
	return @"";
}

- (NSString *) description {
	return [self asXmlWithLevel: 0];
}

- (void) translatePath {
}

- (void) registerViewController:(UIViewController*) controller {
    // Delegate to MBPage
    [[self parent] registerViewController:controller];    
}

-(NSMutableArray*) filterSet:(NSMutableArray*) set usingSelector:(SEL) selector havingValue:(id) value {
    NSMutableArray* result = [[NSMutableArray new] autorelease];
    for(MBComponent *comp in set) {
        if([comp respondsToSelector: selector] && [[comp performSelector: selector] isEqual: value]) {
            [result addObject: comp];    
        }
    }
    return result;
}

- (id) firstDescendantOfKind:(Class) clazz {
    NSMutableArray *result = [self descendantsOfKind:clazz];
	if([result count] == 0) return nil;
	return [result objectAtIndex:0];
}

- (id) firstDescendantOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value {
    NSMutableArray *result = [self descendantsOfKind:clazz filterUsingSelector:selector havingValue:value];
	if([result count] == 0) return nil;
	return [result objectAtIndex:0];
}

- (id) firstChildOfKind:(Class) clazz {
    NSMutableArray *result = [self childrenOfKind:clazz];
	if([result count] == 0) return nil;
	return [result objectAtIndex:0];
}

- (id) firstChildOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value {
    NSMutableArray *result = [self childrenOfKind:clazz filterUsingSelector:selector havingValue:value];
	if([result count] == 0) return nil;
	return [result objectAtIndex:0];
}

- (NSMutableArray*) descendantsOfKind:(Class) clazz {
	// This method is overridden by the various subclasses; if this could be an abstract method it would be
	return [NSMutableArray array];
}

- (NSMutableArray*) descendantsOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value {
	NSMutableArray *descendants = [self descendantsOfKind: clazz];
    return [self filterSet: descendants usingSelector: selector havingValue: value];
}

- (NSMutableArray*) childrenOfKind:(Class) clazz {
	// This method is overridden by the various subclasses; if this could be an abstract method it would be
	return [NSMutableArray array];
}

- (NSMutableArray*) childrenOfKind:(Class) clazz filterUsingSelector:(SEL) selector havingValue:(id) value {
	NSMutableArray *children = [self childrenOfKind: clazz];
    return [self filterSet: children usingSelector: selector havingValue: value];
}

// Listener logic is handled by the page; so delegate to parent until the page is reached:
- (void) registerValueChangeListener:(id<MBValueChangeListenerProtocol>) listener forPath:(NSString*) path {
	[[self parent] registerValueChangeListener: listener forPath:path];
}

- (void) unregisterValueChangeListener:(id<MBValueChangeListenerProtocol>) listener forPath:(NSString*) path {
	[[self parent] unregisterValueChangeListener: listener forPath:path];
}

- (void) unregisterValueChangeListener:(id<MBValueChangeListenerProtocol>) listener {
	[[self parent] unregisterValueChangeListener: listener];
}

- (BOOL) notifyValueWillChange:(NSString*) value originalValue:(NSString*) originalValue forPath:(NSString*) path {
	
	return [[self parent] notifyValueWillChange: value originalValue: originalValue forPath: path];
}

- (void) notifyValueChanged:(NSString*) value originalValue:(NSString*) originalValue forPath:(NSString*) path {
	[[self parent] notifyValueChanged: value originalValue: originalValue forPath: path];	
}

- (NSString*) name {
	return self.definition.name;	
}

-(NSString *) customAttributeForKey:(NSString *)key {
	NSString *fetchedLocal = [_customAttributes valueForKey:key];
	if (fetchedLocal) return fetchedLocal;
	else return [self.definition.customAttributes objectForKey:key];
}

-(void)setCustomAttribute:(NSString *)value forKey:(NSString *)key {
	if (!_customAttributes) _customAttributes = [[NSMutableDictionary alloc] init];
	[_customAttributes setValue:value forKey:key];
}

@end
