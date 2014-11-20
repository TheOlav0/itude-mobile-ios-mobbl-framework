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

#import "MBMacros.h"
#import "MBXmlDocumentParser.h"
#import "MBDocumentFactory.h"
#import "MBDocument.h"
#import "MBDocumentDefinition.h"
#import "StringUtilities.h"

@interface MBXmlDocumentParser()
- (void) doParseFragment:(NSData *)data intoDocument:(MBDocument*) document rootPath:(NSString*) rootPath copyRootAttributes:(BOOL) copyRootAttributes;
@end

@implementation MBXmlDocumentParser

-(MBDocument*) documentWithData:(NSData *)data andDefinition: (MBDocumentDefinition*) definition {
    MBXmlDocumentParser *documentParser = [[MBXmlDocumentParser alloc]init];
    MBDocument *result = [documentParser parse: data usingDefinition: definition];
    [documentParser release];
    return result;
}

+ (void) parseFragment:(NSData *)data intoDocument:(MBDocument*) document rootPath:(NSString*) rootPath copyRootAttributes:(BOOL) copyRootAttributes {
    MBXmlDocumentParser *documentParser = [[MBXmlDocumentParser alloc]init];
    [documentParser doParseFragment:data intoDocument:document rootPath:rootPath copyRootAttributes: copyRootAttributes];
    [documentParser release];
}

- (MBDocument*) parse:(NSData *)data usingDefinition: (MBDocumentDefinition*) definition {
	
	if(data == nil) return nil;
	
	MBDocument *doc = [[[MBDocument alloc] initWithDocumentDefinition: definition] autorelease];
	[self doParseFragment:data intoDocument:doc rootPath:nil copyRootAttributes: FALSE];
	return doc;
}

- (void) doParseFragment:(NSData *)data intoDocument:(MBDocument*) document rootPath:(NSString*) rootPath copyRootAttributes:(BOOL) copyRootAttributes {

	if(data != nil) {
		NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
		[xmlParser setDelegate:self];
		
		_stack = [[NSMutableArray alloc] init];
		_pathStack = [[NSMutableArray alloc] init];
		_definition = document.definition;
		_characters = nil;
        _copyRootAttributes = copyRootAttributes;
		
		if(rootPath != nil) {
			NSArray *parts = [rootPath splitPath];
			for(NSString *part in parts) {
				[_pathStack addObject:[part stripCharacters:@"[]0123456789"]];	
			}
			_rootElementName = [_pathStack lastObject];
			_rootElement = [document valueForPath:rootPath];
		}
		else {
			_rootElement = document;
            // Use the rootElement as name. If it is not provided, use the documentName
            _rootElementName = _definition.rootElement;
            if (!_rootElementName) {
                _rootElementName = _definition.name;
            }
			
		}
		
		[xmlParser parse];
		
		[_stack release];
		[_pathStack release];
		[_characters release];
		[xmlParser release];
	}
}

-(NSString*) currentPath {
	NSMutableString *path = [NSMutableString stringWithString: @""];
	for(NSString *part in _pathStack) [path appendFormat:@"/%@", part];
	return path;
}

// begin element
-(void)  parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName 
	 attributes:(NSDictionary *)attributeDict {
	
	[_characters release];
	_characters = [NSMutableString new];
	
    MBElement *element = nil;
    BOOL copyAttributes = TRUE;
    
	// check that we have the correct document type
	if([_stack count] == 0)
	{
		if(![elementName isEqualToString:_rootElementName]) {
			NSString *msg = [NSString stringWithFormat:@"Error parsing document %@: encountered an element with name %@ but expected %@", 
							 _definition.name, elementName, _rootElementName];
			@throw [NSException exceptionWithName:@"InvalidDocument" reason: msg userInfo:nil];
		}
        element = (MBElement*)_rootElement;
        copyAttributes = _copyRootAttributes;
	}
	else {
		[_pathStack addObject:elementName];
		MBElementDefinition *elementDefinition = [_definition elementWithPathComponents:[NSMutableArray arrayWithArray:_pathStack]];
        if (elementDefinition == nil) {
			WLog(@"Found unexpected element with name '%@'. Check element definition.", elementName);
        } 
        element = [[[MBElement alloc] initWithDefinition: elementDefinition] autorelease];
        if(element != nil) [[_stack lastObject] performSelector:@selector(addElement:) withObject:element];
	}
    
    // Do not process elements that are not defined; so also check for nil definition
    if(copyAttributes && element.definition != nil) {
        for(NSString *attrName in [attributeDict allKeys]) [element setValue:[attributeDict valueForKey:attrName] forAttribute:attrName throwIfInvalid:FALSE];
    }
    [_stack addObject:element];
}

// end element
-(void) parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
	
	if ([_stack count] > 1) 
	{
		if([_characters length]>0) {
			if([[_stack lastObject] isValidAttribute:@"text()"]) {
				[[_stack lastObject] setValue: _characters forAttribute: @"text()"];
			} 
			else {
				WLog(@"Warning: Text (%@) specified in body of element %@ is ignored because the element has no text() attribute defined", _characters, elementName);
			}
		}
		[_stack removeLastObject];
		[_pathStack removeLastObject];
	}
	[_characters release];
	_characters = nil;
}

- (void) parser:(NSXMLParser *)parser 
foundCharacters:(NSString *)string {
	[_characters appendString:string];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	
	NSString *msg = [NSString stringWithFormat:@"Error parsing document %@ at line %i column %i: %@", 
					 _definition.name, [parser lineNumber], [parser columnNumber],  [parseError description]];
	@throw [NSException exceptionWithName:@"ParseError" reason: msg userInfo:nil];
	
}


@end


