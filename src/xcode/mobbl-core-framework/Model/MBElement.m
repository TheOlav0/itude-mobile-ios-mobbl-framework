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

#import "MBElement.h"
#import "MBAttributeDefinition.h"
#import "MBDocumentDefinition.h"
#import "StringUtilities.h"

@interface MBElement()
  -(void) setDefinition:(MBElementDefinition*) definition;
  -(NSString*) cookValue:(NSString*) uncooked;
@end

@interface MBElementContainer()
- (void) copyChildrenInto:(MBElementContainer*) other;
- (void) addAllPathsTo:(NSMutableSet*) set currentPath:(NSString*) currentPath;
@end

@implementation MBElement

-(id) initWithDefinition:(id) definition {
	self = [super init];
	if (self != nil) {
		self.definition = definition;
		_values = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return self;
}

- (void) dealloc
{
	[_definition release];
	[_values release];
	[super dealloc];
}

- (id) copy {
	MBElement *newElement = [[MBElement alloc] initWithDefinition: self.definition];
	[newElement->_values addEntriesFromDictionary:_values];
	[self copyChildrenInto: newElement];
	return newElement;
}

- (BOOL)isEqualToElement:(MBElement *)element {
    return [self isEqualToElementContainer:element];
}

- (void) assignByName:(MBElementContainer*) other {
	[other deleteAllChildElements];

	MBElementDefinition *def = self.definition;
	for(MBAttributeDefinition *attrDef in [def attributes]) {
		if([other.definition isValidAttribute: attrDef.name]) {
			[other setValue:[self valueForAttribute: attrDef.name] forKey:attrDef.name];
		}
	}
	
	for(NSString *elementName in [_elements allKeys]) {
		for(MBElement *src in [_elements valueForKey:elementName]) {
			MBElement *newElem = [other createElementWithName: src.definition.name];
			[src assignByName:newElem];
		}
	}
}

- (void) assignToElement:(MBElement*) target {
	if(![target->_definition.name isEqualToString:_definition.name]) {
		NSString *msg = [NSString stringWithFormat:@"Cannot assign element since types differ: %@ != %@ (use assignByName:)", target->_definition.name, _definition.name];
		@throw [NSException exceptionWithName:@"CannotAssign" reason:msg userInfo:nil];
		
	}
	[target->_values removeAllObjects];
	[target->_values addEntriesFromDictionary:_values];
	[target->_elements removeAllObjects];
	[self copyChildrenInto: target];
}

- (NSString*) uniqueId {
	NSMutableString *uid = [NSMutableString stringWithCapacity:200];
	[uid appendFormat:@"%@", [self definition].name];
	for(MBAttributeDefinition* def in [_definition attributes]) {
		NSString *attrName = def.name;
		if(![attrName isEqualToString:@"xmlns"]) {
			NSString *attrValue = [_values objectForKey: attrName];
			[uid appendString: @"_"];
			if (attrValue) [uid appendString: [self cookValue: attrValue]];
		}
	}
	[uid appendString:[super uniqueId]];
	return uid;
}

-(void) addAllPathsTo:(NSMutableSet*) set currentPath:(NSString*) currentPath {
	
	NSString *elementName = [[self definition]name];
#pragma unused(elementName)
	
	for(NSString *attr in [_values allKeys]) {
		[set addObject: [NSString stringWithFormat:@"%@/@%@", currentPath, attr]]; 	
	}
	[super addAllPathsTo:set currentPath:currentPath];
}


- (id) valueForPathComponents:(NSMutableArray*)pathComponents withPath: (NSString*) originalPath nillIfMissing:(BOOL) nillIfMissing translatedPathComponents:(NSMutableArray*)translatedPathComponents {
    if([pathComponents count] > 0 && [[pathComponents objectAtIndex:0] hasPrefix:@"@"]) {
	   NSString *attrName = [pathComponents objectAtIndex:0];
		[translatedPathComponents addObject:attrName];
	   return [self valueForAttribute: [attrName substringFromIndex:1]];
	}
	else return [super valueForPathComponents: pathComponents withPath:originalPath nillIfMissing: nillIfMissing translatedPathComponents:translatedPathComponents];
}

-(BOOL) isValidAttribute:(NSString*) attributeName {
	return [[self definition] isValidAttribute: attributeName];
}

-(void) validateAttribute:(NSString*) attributeName {
	if(![self isValidAttribute: attributeName]) {
     	NSString *msg = [NSString stringWithFormat:@"Attribute %@ not defined for element %@. Use one of %@", attributeName, [[self definition] name], [[self definition] attributeNames]];
     	@throw [NSException exceptionWithName: @"InvalidAttributeName" reason:msg userInfo:nil];
	}
}

-(void) setValue:(NSString *)value forPath:(NSString *)path {
	if([path hasPrefix:@"@"]) [self setValue:value forAttribute:[path substringFromIndex:1]];
	else [super setValue:value forPath:path];
}

-(void) setValue:(id)value forAttribute:(NSString *)attributeName {
	[self setValue:value forAttribute:attributeName throwIfInvalid: TRUE];	
}

- (void) setValue:(id)value forAttribute:(NSString *)attributeName throwIfInvalid:(BOOL) throwIfInvalid {
   	if(throwIfInvalid) {
		[self validateAttribute: attributeName];
        if (value)
            [_values setObject:value forKey:attributeName];
        else
            [_values removeObjectForKey:attributeName];
	}
	else {
        if([self isValidAttribute: attributeName]) {
            if (value) [_values setObject:value forKey:attributeName];
            else [_values removeObjectForKey:attributeName];
        }
	}
}

-(NSString*) valueForAttribute:(NSString*)attributeName {
	[self validateAttribute: attributeName];
	id result =  [_values objectForKey:attributeName];
    return result;
}

-(id) valueForKey:(NSString *)key {
	return [self valueForAttribute:key];	
}

-(void) setValue:(id)value forKey:(NSString *)key {
	[self setValue:value forAttribute:key];	
}

-(void) setDefinition:(MBElementDefinition*) definition {
	[definition retain];
	_definition = definition;
}

- (id) definition {
	return _definition;
}

-(NSString*) cookValue:(NSString*) uncooked {
	if(uncooked == nil) return nil;
	
	NSMutableString *cooked = [NSMutableString stringWithString:@""];
	for(int i=0; i<[uncooked length]; i++) {
		int c = [uncooked characterAtIndex:i];
		if(c < 32 || c=='&' || c=='\'' || c>126) [cooked appendFormat:@"&#%i;", c];
		else [cooked appendFormat:@"%c", c];
	}
	return cooked;
}

-(void) attributeAsXml:(NSString*)name withValue:(id) attrValue withBuffer:(NSMutableString*) buffer {
	
	NSString *escaped = [attrValue xmlSimpleEscape];
    if (attrValue) [buffer appendFormat:@" %@='%@'", name, escaped];
}

- (NSString *) bodyText {
	if([self isValidAttribute: TEXT_ATTRIBUTE]) return [self valueForAttribute:TEXT_ATTRIBUTE];	
	return nil;
}

-(void) setBodyText:(NSString*) text {
	[self setValue:text forAttribute:TEXT_ATTRIBUTE];	
}

- (void) asXml:(NSMutableString*) buffer withLevel:(int)level {
    BOOL hasBodyText = [[self bodyText] length];
    [buffer appendString:[NSString stringWithSpaces:level]];
    [buffer appendString:@"<"];
    [buffer appendString:_definition.name];

    for(MBAttributeDefinition* def in [_definition attributes]) {
        NSString *attrName = def.name;
        NSString *attrValue = [_values objectForKey: attrName];
        if(![attrName isEqualToString:TEXT_ATTRIBUTE]) [self attributeAsXml:attrName withValue:attrValue withBuffer:buffer];
    }
    if([[_definition children] count] == 0 && !hasBodyText)
        [buffer appendString:@"/>\n"];
    else {
        [buffer appendString:@">"];
        if(hasBodyText) {
            NSString *escaped =[self.bodyText xmlSimpleEscape];
            [buffer appendString: escaped];
        }
        else [buffer appendString: @"\n"];
        
        for(MBElementDefinition *elemDef in [_definition children]) {
            NSArray *lst = [[self elements] objectForKey:elemDef.name];
            for(MBElement *elem in lst)
                [elem asXml: buffer withLevel:(level + 2)];
        }
        
        [buffer appendString:[NSString stringWithSpaces:hasBodyText?0:level]];
        [buffer appendString:@"</"];
        [buffer appendString:_definition.name];
        [buffer appendString:@">"];
    }
    
}

- (NSString *) asXmlWithLevel:(int)level
{
    NSMutableString *result = [[NSMutableString new] autorelease];
    [self asXml:result withLevel: level];
    return result;
}

- (NSString *) description {
	return [self asXmlWithLevel: 0];
}

- (NSString *) name {
	return [self definition].name;
}

- (NSInteger) physicalIndexWithCurrentPath: (NSString *)path {
	NSMutableArray *pathComponents = [path splitPath];
	NSString *lastPathComponent = [pathComponents objectAtIndex:[pathComponents count] - 1];
	NSArray *elementComponentParts = [lastPathComponent componentsSeparatedByString:@"["];
	NSString *elementName = [elementComponentParts objectAtIndex:0];
	
	if([elementName isEqualToString: [self name]]) {
		NSMutableString *idxStr = [NSMutableString stringWithString: [elementComponentParts objectAtIndex:1]];
		[idxStr replaceOccurrencesOfString:@"]" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [idxStr length])];
		return [idxStr intValue];
	}else {
		NSString *msg = [NSString stringWithFormat:@"Path %@ not for element %@.", path, [self name]];
     	@throw [NSException exceptionWithName: @"InvalidElementPath" reason:msg userInfo:nil];
	}
    
	return -1;
}

@end
