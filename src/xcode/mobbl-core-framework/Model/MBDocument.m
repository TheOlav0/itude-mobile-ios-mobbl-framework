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

#import "MBDocument.h"
#import "MBDocumentDefinition.h"
#import "MBDataManagerService.h"

@interface MBElementContainer()
- (void) copyChildrenInto:(MBElementContainer*) other;
@end

@implementation MBDocument

@synthesize sharedContext = _sharedContext;
@synthesize argumentsUsed = _argumentsUsed;

- (id) initWithDocumentDefinition: (MBDocumentDefinition*) definition {
	if (self = [super init]) {
		_definition = definition;
		_sharedContext = [NSMutableDictionary new];
		[_definition retain];
		_pathCache = [NSMutableDictionary new];
	}
	return self;	
}

- (id) initWithDocumentDefinition:(MBDocumentDefinition *)definition withDataManagerService:(MBDataManagerService *) dataMangerService
{
    _dataManagerService = dataMangerService;
    return [self initWithDocumentDefinition:definition];
}

- (void) dealloc
{
	[_definition release];
	[_sharedContext release];
	[_argumentsUsed release];
	[_pathCache release];
	[super dealloc];
}

- (id) copy {
	MBDocument *newDoc = [[MBDocument alloc] initWithDocumentDefinition:_definition];
	[self copyChildrenInto: newDoc];
	newDoc->_argumentsUsed = [_argumentsUsed copy];
	return newDoc;
}

- (void) assignToDocument:(MBDocument*) target {
	if(![target->_definition.name isEqualToString:_definition.name]) {
		NSString *msg = [NSString stringWithFormat:@"Cannot assign document since document types differ: %@ != %@", target->_definition.name, _definition.name];
		@throw [NSException exceptionWithName:@"CannotAssign" reason:msg userInfo:nil];

	}
	[target->_elements removeAllObjects];
	[target->_pathCache removeAllObjects];
	[self copyChildrenInto: target];
}

- (BOOL)isEqualToDocument:(MBDocument *)document {
    return [self isEqualToElementContainer:document];
}

- (NSString*) uniqueId {
	NSMutableString *uid = [NSMutableString stringWithCapacity:200];
	
	// Specification: the uniqueId of a document starts with <docname>:
	// This is required for the cache manager to determine the document type
	[uid appendFormat:@"%@:", _definition.name];
	[uid appendString:[super uniqueId]];
	return uid;
}

- (void) clearAllCaches {
	[self.sharedContext removeAllObjects];	
	[self clearPathCache];
}
	 
// Be careful with reload since it might change the number of elements; making any existing path (indexes) invalid
// It is safer to use loadFreshCopyForDelegate:resultSelector:errorSelector: and process the result in the callbacks
- (void) reload {

	MBDocument *fresh;
	
	if(_argumentsUsed == nil) fresh = [[self dataManagerService] loadDocument:_definition.name];
	else fresh = [ [self dataManagerService] loadFreshDocument:_definition.name withArguments: _argumentsUsed];
	[_elements release];
	_elements = [[fresh elements] retain];
	[_pathCache removeAllObjects];
}

-(void) loadFreshCopyForDelegate:(id) delegate resultSelector:(SEL) resultSelector errorSelector:(SEL)errorSelector {
	[[self dataManagerService] loadFreshDocument:_definition.name withArguments:_argumentsUsed forDelegate:delegate resultSelector:resultSelector errorSelector:errorSelector];
}



- (NSString *) asXmlWithLevel:(int)level
{
    NSString *elementName = _definition.rootElement ? _definition.rootElement : _definition.name;
	NSMutableString *result = [NSMutableString stringWithFormat: @"%*s<%@", level, "", elementName];
	if([[self elements] count] == 0)
		[result appendString:@"/>\n"];
	else {
		[result appendString:@">\n"];
		for(MBElementDefinition *elemDef in [_definition children]) {
			NSArray *lst = [[self elements] objectForKey:elemDef.name];
            for(MBElement *elem in lst)
                [elem asXml: result withLevel:(level + 2)];
		}
		[result appendFormat:@"%*s</%@>\n", level, "", elementName];
	}
	
	return result;
}

- (void) clearPathCache {
	[_pathCache removeAllObjects];
}

- (id) valueForPath:(NSString*)path {
	NSArray *comps = [path componentsSeparatedByString:@"@"];
	if([comps count] != 2) return [self valueForPath:path translatedPathComponents:nil];
	
	MBElement *element = [_pathCache valueForKey:[comps objectAtIndex:0]];
	
	if(element == nil) {
		element = [super valueForPath:[comps objectAtIndex:0]];
		[_pathCache setValue:element forKey:[comps objectAtIndex:0]];
	} 	
	return [element valueForAttribute:[comps objectAtIndex:1]];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Document with name %@:\n %@", _definition.name, [self asXmlWithLevel:0]];
}

- (id) definition {
	return _definition;
}

- (NSString*) documentName {
	return _definition.name;
}

-(MBDocument*) document {
	return self;
}

-(MBDataManagerService*) dataManagerService
{
    if(!_dataManagerService)
    {
        _dataManagerService = [MBDataManagerService sharedInstance];
    }
    return _dataManagerService;
}


@end
