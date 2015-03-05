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

#import "MBPanel.h"
#import "MBPanelDefinition.h"
#import "MBForEach.h"
#import "MBForEachDefinition.h"
#import "MBField.h"
#import "MBFieldDefinition.h"
#import "MBComponentFactory.h"
#import "MBViewBuilderFactory.h"
#import "MBPanelViewBuilder.h"
#import "MBDefinition.h"
#import "MBLocalizationService.h"

@interface MBPanel() {
    NSString *_translatedPath;
}
    @property (nonatomic, retain) NSString *translatedPath;
@end

@implementation MBPanel

@synthesize type = _type;
@synthesize title = _title;
@synthesize titlePath = _titlePath;
@synthesize zoomable = _zoomable;
@synthesize width = _width;
@synthesize height = _height;
@synthesize outcomeName = _outcomeName;
@synthesize path = _path;
@synthesize translatedPath = _translatedPath;

-(id) initWithDefinition:(MBPanelDefinition *)definition document:(MBDocument*) document parent:(MBComponentContainer *) parent {
    return [self initWithDefinition: definition document: document parent: parent buildViewStructure: TRUE];
}

-(id) initWithDefinition:(MBPanelDefinition *)definition document:(MBDocument*) document parent:(MBComponentContainer *) parent buildViewStructure:(BOOL) buildViewStructure {
	self = [super initWithDefinition:definition document: document parent: parent];
	if (self != nil) {
		self.title = definition.title;
        self.titlePath = [self substituteExpressions:definition.titlePath];
		self.type = definition.type;
		self.width = definition.width;
		self.height = definition.height;
        self.zoomable = definition.zoomable;
        self.outcomeName = definition.outcomeName;
        self.path = definition.path;

		if(buildViewStructure) {
            for(MBDefinition *def in definition.children) {
                if([def isPreConditionValid:document currentPath:[parent absoluteDataPath]]) [self addChild: [MBComponentFactory componentFromDefinition: def document: document parent: self]];
            }
        }
	}
	return self;
}

- (void) rebuild {
	[self.children removeAllObjects];
	MBPanelDefinition *panelDef = (MBPanelDefinition*)[self definition];
	for(MBDefinition *def in [panelDef children]) {
		if([def isPreConditionValid:self.document currentPath:[self.parent absoluteDataPath]]) [self addChild: [MBComponentFactory componentFromDefinition: def document: self.document parent: self]];
	}
}

- (void) dealloc
{
    [_titlePath release];
    [_title release];
	[_type release];
    [_outcomeName release];
    [_path release];
    [_translatedPath release];
	[super dealloc];
}

// This will translate any expression that are part of the path to their actual values
- (void) translatePath {
	self.translatedPath = [self substituteExpressions:[self absoluteDataPath]];
    [super translatePath];
}

-(NSString *) absoluteDataPath {
	if(self.translatedPath != nil) return self.translatedPath;
	return [super absoluteDataPath];
}

-(NSString*) title {
	NSString *result = nil;
	
	if(_title != nil) result = _title;
	else {
		MBPanelDefinition *definition = (MBPanelDefinition*)[self definition];
		if(definition.title != nil) result = definition.title;
		else if(definition.titlePath != nil) {
			NSString *path = self.titlePath;
			if(![path hasPrefix:@"/"]) path = [NSString stringWithFormat:@"%@/%@", [self absoluteDataPath], path];
			// Do not localize data coming from documents; which would become very confusing
			return [[self document] valueForPath: path];
		}
	}
	return MBLocalizedStringWithoutLoggingWarnings(result);
}

- (NSString *) asXmlWithLevel:(int)level {
	NSMutableString *result = [NSMutableString stringWithFormat: @"%*s<MBPanel%@%@%@%@%@%@%@>\n", level, "",
							   [self attributeAsXml:@"type" withValue:_type],
							   [self attributeAsXml:@"title" withValue:_title],
							   [self attributeAsXml:@"width" withValue:[NSString stringWithFormat:@"%i", _width]],
							   [self attributeAsXml:@"height" withValue:[NSString stringWithFormat:@"%i", _height]],
                               [self attributeAsXml:@"zoomable" withValue:@(_zoomable)],
                               [self attributeAsXml:@"outcome" withValue:_outcomeName],
                               [self attributeAsXml:@"style" withValue:self.style]
							   ];
	
    [result appendString: [self childrenAsXmlWithLevel: level+2]];
	[result appendFormat:@"%*s</MBPanel>\n", level, ""];
	
	return result;
}

-(int) leftInset {
	//if([self.type isEqualToString:@"LIST"] || [self.type isEqualToString:@"MATRIX"]) return 10;
	//else 
	return [super leftInset];
}

-(int) rightInset {
	//if([self.type isEqualToString:@"LIST"] || [self.type isEqualToString:@"MATRIX"]) return 10;
	//else 
	return [super rightInset];
}

-(int) topInset {
	//if([self.type isEqualToString:@"LIST"] || [self.type isEqualToString:@"MATRIX"]) return 0;
	//else 
	return [super topInset];
}

-(int) bottomInset {
	//if([self.type isEqualToString:@"LIST"] || [self.type isEqualToString:@"MATRIX"]) return 10;
	//else 
	return [super bottomInset];
}

@end
