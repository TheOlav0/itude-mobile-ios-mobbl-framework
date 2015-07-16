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

#import "MBDefinition.h"


@implementation MBDefinition

@synthesize name = _name;

- (void) dealloc
{
	[_name release];
	[_customAttributes release];
	[super dealloc];
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

-(void) validateDefinition {
	
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	id	stringSelector = NSStringFromSelector(sel);
	int	parameterCount = [[stringSelector componentsSeparatedByString:@":"] count]-1i;
	
	// Zero argument, forward to valueForKey:
	if (parameterCount == 0)
		return [super methodSignatureForSelector:@selector(valueForKey:)];
	
	// One argument starting with set, forward to setValue:forKey:
	if (parameterCount == 1 && [stringSelector hasPrefix:@"add"])
		return [super methodSignatureForSelector:@selector(setValue:forKey:)];
	
	// Discard the call
	return nil;
}

// Call valueForKey: and setValue:forKey: 
- (void)forwardInvocation:(NSInvocation *)invocation
{
	id	stringSelector = NSStringFromSelector([invocation selector]);
	int	parameterCount = [[stringSelector componentsSeparatedByString:@":"] count]-1i;
	
	// Forwarding to setValue:forKey:
	if (parameterCount == 1)
	{
		id argument;
		// The first parameter to an ObjC method is the third argument
		// ObjC methods are C functions taking instance and selector as their first two arguments
		[invocation getArgument:&argument atIndex:2];
		
		NSString* msg = [NSString stringWithFormat:@"Check configuration.xml:\n%@does not implement %@ with argument %@", [self asXmlWithLevel:10], stringSelector, argument];
		@throw [NSException exceptionWithName:@"UnrecognizedSelector" reason:msg userInfo:nil];
	} 
	else 
		@throw [NSException exceptionWithName:@"UnrecognizedSelector" reason:stringSelector userInfo:nil];
}

- (BOOL) isPreConditionValid {
    return TRUE;
}

- (BOOL) isPreConditionValid:(MBDocument*) document  currentPath:(NSString*) currentPath {
	return TRUE;	
}

@end
