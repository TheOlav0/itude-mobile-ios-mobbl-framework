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

#import "MBOutcome.h"
#import "MBOutcomeDefinition.h"
#import "MBDataManagerService.h"
#import "MBConfigurationDefinition.h"

@implementation MBOutcome

@synthesize originName = _originName;
@synthesize outcomeName = _outcomeName;
@synthesize pageStackName = _pageStackName;
@synthesize originPageStackName = _originPageStackName;
@synthesize displayMode = _displayMode;
@synthesize transitionStyle = _transitionStyle;
@synthesize document = _document;
@synthesize path = _path;
@synthesize persist = _persist;
@synthesize transferDocument = _transferDocument;
@synthesize preCondition = _preCondition;
@synthesize noBackgroundProcessing = _noBackgroundProcessing;
@synthesize processingMessage = _processingMessage;

-(id) initWithOutcome:(MBOutcome*) outcome {
    if(self = [super init]) {
        self.originName = outcome.originName;
        self.outcomeName = outcome.outcomeName;
        self.originPageStackName = outcome.originPageStackName;
        self.pageStackName = outcome.pageStackName;
        self.displayMode = outcome.displayMode;
        self.transitionStyle = outcome.transitionStyle;
        self.document = outcome.document;
        self.path = outcome.path;
        self.persist = outcome.persist;
        self.transferDocument = outcome.transferDocument;
        self.preCondition = outcome.preCondition;
        self.noBackgroundProcessing = outcome.noBackgroundProcessing;
        self.processingMessage = outcome.processingMessage;
        _action = [outcome.action retain];
    }
    return self;
}

-(id) initWithOutcomeName:(NSString *)outcomeName
				 document:(MBDocument *)document {
	if(self = [super init]) {
		self.outcomeName = outcomeName;
		self.document = document;
	}
	return self;
}

-(id) initWithOutcomeName:(NSString *)outcomeName
				 document:(MBDocument *)document 
			   pageStackName:(NSString*) pageStackName {
	if(self = [self initWithOutcomeName: outcomeName document: document]) {
		self.pageStackName = pageStackName;
	}
	return self;
}

-(id) initWithOutcomeDefinition:(MBOutcomeDefinition*) definition {
	if(self = [super init]) {
		self.originName = definition.origin;
		self.outcomeName = definition.name;
		self.pageStackName = definition.pageStackName;
        
        // Backwards compatibility: We set the dialog in case we have no pageStackName.
        if (!self.pageStackName) {
            self.pageStackName = definition.dialog;
        }
        
		self.displayMode = definition.displayMode;
        self.transitionStyle = definition.transitionStyle;
		self.persist = definition.persist;
		self.transferDocument = definition.transferDocument;
		self.noBackgroundProcessing = definition.noBackgroundProcessing;
		self.document = nil;
		self.document = nil;
		self.path = nil;	
        self.preCondition = definition.preCondition;
        self.processingMessage = definition.processingMessage;
        _action = [definition.action retain];
	}
	return self;
}

-(void) dealloc {
	[_originName release];
	[_outcomeName release];
	[_pageStackName release];
    [_originPageStackName release];
    [_displayMode release];
    [_transitionStyle release];
    [_path release];
	[_document release];
	[_preCondition release];
    [_processingMessage release];
    [_action release];
	[super dealloc];
}

-(BOOL) isPreConditionValid {

	if(self.preCondition == nil) return TRUE;
	MBDocument *doc = self.document;
	
	if(doc == nil) doc = [[MBDataManagerService sharedInstance]loadDocument:DOC_SYSTEM_EMPTY];
	NSString *result = [doc evaluateExpression:_preCondition];
	result = [result uppercaseString];
	if([@"1" isEqualToString:result] || [@"YES" isEqualToString:result] || [@"TRUE" isEqualToString:result]) return TRUE;
	if([@"0" isEqualToString:result] || [@"NO" isEqualToString:result]  || [@"FALSE" isEqualToString:result]) return FALSE;
	
	NSString *msg = [NSString stringWithFormat:@"Expression of outcome with origin=%@ name=%@ preCondition=%@ is not boolean (%@)", _originName, _outcomeName, _preCondition, result];
	@throw [NSException exceptionWithName:@"ExpressionNotBoolean" reason:msg userInfo: nil];
}

-(NSString *) description {
	return [NSString stringWithFormat:@"Outcome: pageStackName=%@ originName=%@ outcomeName=%@ path=%@ persist=%@ displayMode=%@ transitionStyle=%@ preCondition=%@ noBackgroundProsessing=%@  processingMessage=%@", 
            self.pageStackName, _originName, _outcomeName, _path,  _persist?@"TRUE":@"FALSE", _displayMode, _transitionStyle, _preCondition, _noBackgroundProcessing?@"TRUE":@"FALSE", _processingMessage];
}

@end
