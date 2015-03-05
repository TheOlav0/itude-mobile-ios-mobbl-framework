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

#import "MBForEachItem.h"
#import "MBForEachDefinition.h"
#import "MBViewBuilderFactory.h"
#import "MBPage.h"

@implementation MBForEachItem

@synthesize index = _index;

- (void) dealloc
{
	[super dealloc];
}

-(NSString *) componentDataPath {
	MBForEachDefinition *def = (MBForEachDefinition*)[self definition];
	NSString *path = [NSString stringWithFormat:@"%@[%i]", [def value], _index];
	return [self substituteExpressions: path];
}

-(NSString*) evaluateExpression:(NSString*) variableName {
	MBForEachDefinition *eachDef = (MBForEachDefinition*) [[self parent] definition];
	MBVariableDefinition *varDef = [eachDef variable: variableName];
	if(varDef == nil) return [[self parent] evaluateExpression:variableName];
	
	if([@"currentPath()" isEqualToString:varDef.expression]||[@"currentpath()" isEqualToString:varDef.expression]) return [self absoluteDataPath];
	if([@"rootPath()"    isEqualToString:varDef.expression]||[@"rootpath()"    isEqualToString:varDef.expression]) return [[self page] rootPath];
	
	NSString *value;
	if([varDef.expression hasPrefix:@"/"] || [varDef.expression rangeOfString:@":"].length > 0) {
		value = varDef.expression;
	}
	else {
		NSString *componentPath = [self substituteExpressions: [self componentDataPath]];
        
        //start: added by Xiaochen
        //in config file, when the expression of a variable does not contain ":" or a prefix "/", componentPath needs to be reset. 
		if(![componentPath hasPrefix:@"/"] && [componentPath rangeOfString:@":"].length == 0) {
			componentPath = [NSString stringWithFormat:@"%@/%@", [self.page absoluteDataPath], componentPath];
		}
		//end.
        
		value = [NSString stringWithFormat:@"%@/%@", componentPath, varDef.expression];
	}
	return [[self document] valueForPath: value];
}

- (NSString *) asXmlWithLevel:(int)level {
	NSMutableString *result = [NSMutableString stringWithFormat: @"%*s<MBRow index=%i>\n", level, "", _index];
    [result appendString: [self childrenAsXmlWithLevel: level+2]];
	[result appendFormat:@"%*s</MBRow>\n", level, ""];
	
	return result;
}

@end
