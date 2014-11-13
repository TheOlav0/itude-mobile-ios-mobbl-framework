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

#import "MBElementContainer+Preconditions.h"
#import "MBMacros.h"
#import "StringUtilities.h"

#import "MBDocument.h"

@implementation MBElementContainer (Preconditions)

- (int) evaluateIndexExpression:(NSString*) combinedExpression forElementName:(NSString*) elementName {
	NSMutableArray *matchAttributes = [[NSMutableArray new] autorelease];
	NSMutableArray *matchValues = [[NSMutableArray new] autorelease];
    
	NSArray *expressions = [combinedExpression componentsSeparatedByString:@" and "];
	
	for(NSString *expression in expressions) {
        
		int eqPos = [expression rangeOfString:@"="].location;
		NSString *attrName = [[expression substringToIndex:eqPos] stripCharacters:@" "];
		NSMutableString *valueExpression = [NSMutableString stringWithString:[expression substringFromIndex:eqPos+1]];
		
		attrName = [self substituteExpressions:attrName usingNilMarker:attrName currentPath:nil];
		[valueExpression replaceOccurrencesOfString:@"'" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [valueExpression length])];
		[valueExpression replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [valueExpression length])];
		NSString *value = [self substituteExpressions:valueExpression usingNilMarker:valueExpression currentPath:nil];
        
		[matchAttributes addObject:attrName];
		[matchValues addObject:value];
	}
	
    
	NSMutableArray *elements = [self elementsWithName:elementName];
	for(int i = 0; i< elements.count; i++) {
		BOOL match = TRUE;
		for(int j=0; match && j<[matchAttributes count]; j++) {
			NSString *attrName = [matchAttributes objectAtIndex:j];
			NSString *value = [matchValues objectAtIndex:j];
			match &= [[[elements objectAtIndex:i] valueForAttribute: attrName] isEqualToString:value];
		}
		if(match) return i;
	}
	
	// Return an index that exceeds the size of the elements array; this will be handled by if([rootList count] <= idx) below
	// i.e. if nillIfMissing is TRUE then a not matching expression will also return nil because of this:
	return elements.count;
}

-(NSString*) substituteExpressions:(NSString*) expression usingNilMarker:(NSString*) nilMarker currentPath:(NSString*) currentPath {

    if(expression == nil) return nil;
    if([expression rangeOfString:@"{"].length == 0) return expression;
    
    NSMutableString *result = [NSMutableString stringWithString:expression];
    
    // Keep a list of indexes with startpoints of an expression
    NSMutableArray *stack = [NSMutableArray array];
    
    unsigned int len = [result length];
    char *buffer = malloc(len + 1);
    [expression getCString:buffer maxLength:(len + 1) encoding:NSUTF8StringEncoding ];
    
    // Search for nested expressions
    // Loop trough all characters in the sting.
    for(int i = 1; i < len; ++i) {
        
        char currentChar = buffer[i];
        
        // Store the character's location if it is a opening tag '${'. We need it later on to get the nested expression
        if (currentChar == '{' && buffer[i-1] == '$') {
            [stack addObject:[NSNumber numberWithInt:i+1]];
        }
        
        // If we found the closing tag, that means we have found the next (sub)expression
        else if (currentChar == '}') {
            // Get the location of the last opening tag
            NSNumber *lastNumber = [stack lastObject];
            int lastOpeningTagPosition = [lastNumber intValue];
            [stack removeLastObject];
            
            // Get the (nested) subExpression
            NSRange range = [self rangeWithLocation:lastOpeningTagPosition length:i-lastOpeningTagPosition];
            NSString *subExpression = [result substringWithRange:range];

            // Substitute the subExpression
            NSString *translated = [self substituteExpression:subExpression usingNilMarker:nilMarker currentPath:currentPath];

            // Replace the expression with the translated value
            // Update the range because we need to include the opening and close tags: ${...}
            range.location -= 2;
            range.length +=3;
            [result deleteCharactersInRange:range];
            [result insertString:translated atIndex:range.location];
            
            // Update buffer, length and i to accomodate for the replaced expression
            i = i - range.length + [translated length];
            len = len - range.length + [translated length];
            buffer = realloc(buffer, len + 1);
            [result getCString:buffer maxLength:(len + 1) encoding:NSUTF8StringEncoding ];

        }
    }
    
    free(buffer);
    
    return result;
}

// Substitutes a SINGLE expression
- (NSString *)substituteExpression:(NSString *)singleExpression usingNilMarker:(NSString*) nilMarker currentPath:(NSString*) currentPath {

    // Concatinate the currentPath with the singleExpression
    if([singleExpression hasPrefix:@"."] && currentPath != nil && [currentPath length]>0) {
        singleExpression = [NSString stringWithFormat:@"%@/%@", currentPath, singleExpression];
    }
    
    // Put the value in the result
    NSString *result = [self valueForPath: singleExpression];
    return (result.length > 0)? result : nilMarker;
}


#pragma mark -
#pragma mark Util

- (NSRange)rangeWithLocation:(NSUInteger)location length:(NSUInteger)length {
    NSRange range;
    range.location = location;
    range.length  = length;
    return range;
}

@end
