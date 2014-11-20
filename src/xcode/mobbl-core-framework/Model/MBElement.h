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

#import "MBElementDefinition.h"
#import "MBElementContainer.h"

#define TEXT_ATTRIBUTE @"text()"

/**
* A node in an Element tree.
*/
@interface MBElement : MBElementContainer {

	@private
	NSMutableDictionary *_values;   // Dictionary of strings
	MBElementDefinition *_definition;
}

/// @name Creating and Initializing an Element
- (id) initWithDefinition:(id) definition;

- (BOOL) isEqualToElement:(MBElement *)element;

/// @name Getting Element Properties
- (NSString *) name;
- (MBElementDefinition*) definition;
/** Gets the physical index of an element with a given path */
- (NSInteger) physicalIndexWithCurrentPath: (NSString *)path;

/// @name Working with Attribute Values
- (NSString*) valueForAttribute:(NSString*)attributeName;
- (void) setValue:(id)value forAttribute:(NSString *)attributeName;
- (void) setValue:(id)value forAttribute:(NSString *)attributeName throwIfInvalid:(BOOL) throwIfInvalid;

/// @name Working with the 'text()' attribute
- (NSString *) bodyText;
- (void) setBodyText:(NSString*) text;

/// @name Checking Existence of Attributes
- (BOOL) isValidAttribute:(NSString*) attributeName;

/// @name Exporting to XML
- (NSString *) asXmlWithLevel:(int)level;
- (void) asXml:(NSMutableString*) buffer withLevel:(int)level;


/// @name Copying Element State
- (void) assignToElement:(MBElement*) target;
- (void) assignByName:(MBElementContainer*) other;

@end
