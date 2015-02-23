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
#import "MBForEach.h"
#import "MBForEachItem.h"
#import "MBDefinition.h"
#import "MBComponentFactory.h"
#import "MBViewBuilderFactory.h"
#import "MBForEachViewBuilder.h"
#import "MBForEachDefinition.h"

@implementation MBForEach

@synthesize rows = _rows;
@synthesize value = _value;

-(id) initWithDefinition:(MBForEachDefinition *)definition document:(MBDocument*) document parent:(MBComponentContainer *) parent {
	self = [super initWithDefinition:definition document: document parent: parent];
	if (self != nil) {
		self.value = definition.value;

		_rows = [NSMutableArray new];
		
		MBForEachDefinition *definition = (MBForEachDefinition*)[self definition];
		if(![definition isPreConditionValid:document currentPath:[parent absoluteDataPath]]) {
			// Our precondition is not true; so we must not exist:
			self.markedForDestruction = TRUE;
		}
		else 
		{
			NSString *fullPath = _value;
			if(![fullPath hasPrefix:@"/"] && [fullPath rangeOfString:@":"].length == 0) {
				fullPath = [NSString stringWithFormat:@"%@/%@", [parent absoluteDataPath], _value];
			}

			id pathResult = [document valueForPath: fullPath];
			if(pathResult != nil) {
				if(![pathResult isKindOfClass:[NSArray class]]) @throw [[[NSException alloc]initWithName:@"InvalidPath" reason:_value userInfo:nil] autorelease];

				for(NSInteger unusedIndex = 0; unusedIndex < [pathResult count]; unusedIndex++) {
					MBForEachItem *row = [[[MBForEachItem alloc] initWithDefinition: [self definition] document: document parent: self] autorelease];
					[self addRow: row];
					for(MBForEachDefinition *childDef in [definition children]) {
						//commented by Xiaochen: ForEach tag in config file with precondition does not work
						//if([childDef isPreConditionValid:document currentPath:[parent absoluteDataPath]]) [row addChild: [MBComponentFactory componentFromDefinition: childDef document: document parent: row]];
						//added by Xiaochen
						if([childDef isPreConditionValid:document currentPath:[row absoluteDataPath]]) [row addChild: [MBComponentFactory componentFromDefinition: childDef document: document parent: row]];
					}
				}
				if(definition.suppressRowComponent) {
				// Prune the rows and ourselves
					for(MBForEachItem *row in _rows) {
						for(MBComponent *child in row.children) {
							[child translatePath];
							[[self parent] addChild:child];
						}
					}
					[_rows removeAllObjects];
					// Now mark ourself for destruction so we will not be added to the child array of our parent.
					self.markedForDestruction = TRUE;
				}
			}
		}
	}	
	return self;
}

- (void) dealloc
{
	[_rows release];
	[_value release];
	[super dealloc];
}

-(void) addRow: (MBForEachItem*) row {
	row.index = (int)[_rows count];
	[_rows addObject:row];
	[row setParent:self];
}

-(BOOL) resignFirstResponder {
	BOOL result = FALSE;
	for(MBForEachItem *row in self.rows) result |= [row resignFirstResponder];
	return result;
}

// This method is overridden because we (may) have to the children of the rows too
- (NSMutableArray*) descendantsOfKind:(Class) clazz {
    
    NSMutableArray *result = [super descendantsOfKind: clazz];
    for(MBForEachItem *child in _rows) {
        if([child isKindOfClass: clazz]) [result addObject: child];
        [result addObjectsFromArray: [child descendantsOfKind: clazz]];
    }
    return result;
}

// This method is overridden because we (may) have to the children of the rows too
- (NSMutableArray*) childrenOfKind:(Class) clazz {
    NSMutableArray *result = [super childrenOfKind: clazz];
    for(MBComponent *child in _rows) {
        if([child isKindOfClass: clazz]) [result addObject: child];
    }
    return result;
}

- (NSString *) asXmlWithLevel:(int)level {
	NSMutableString *result = [NSMutableString stringWithFormat: @"%*s<MBForEach%@>\n", level, "",
							   [self attributeAsXml:@"value" withValue:_value]];
	
	MBForEachDefinition *def = (MBForEachDefinition*) [self definition];
	for (MBVariableDefinition* var in [[def variables] allValues])
		[result appendString:[var asXmlWithLevel:level+2]];
	for (MBForEachItem* child in _rows)
		[result appendString:[child asXmlWithLevel:level+2]];
    
    [result appendString: [self childrenAsXmlWithLevel: level+2]];
	[result appendFormat:@"%*s</MBForEach>\n", level, ""];
	
	return result;
}

@end
