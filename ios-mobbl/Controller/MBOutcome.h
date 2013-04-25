//
//  MBOutcome.h
//  Core
//
//  Created by Robin Puthli on 4/26/10.
//  Copyright 2010 Itude Mobile. All rights reserved.
//

#import "MBDocument.h"

@class MBOutcomeDefinition;

@interface MBOutcome : NSObject {
	NSString *_originName;
	NSString *_outcomeName;
	NSString *_dialogName;
	NSString *_originDialogName;
	NSString *_displayMode;
    NSString *_transitionStyle;
	NSString *_path;
	BOOL _persist;
	BOOL _transferDocument;
	BOOL _noBackgroundProcessing;
	MBDocument *_document;
	NSString *_preCondition;
}

@property (nonatomic, retain) NSString *originName;
@property (nonatomic, retain) NSString *outcomeName;
@property (nonatomic, retain) NSString *pageStackName;
@property (nonatomic, retain) NSString *originDialogName;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *displayMode;
@property (nonatomic, retain) NSString *transitionStyle;
@property (nonatomic, retain) NSString *preCondition;
@property (nonatomic, retain) MBDocument *document;
@property (nonatomic, assign) BOOL persist;
@property (nonatomic, assign) BOOL transferDocument;
@property (nonatomic, assign) BOOL noBackgroundProcessing;

-(id) initWithOutcome:(MBOutcome*) outcome;
-(id) initWithOutcomeDefinition:(MBOutcomeDefinition*) definition;

-(id) initWithOutcomeName:(NSString *)outcomeName
				 document:(MBDocument *)document;

-(id) initWithOutcomeName:(NSString *)outcomeName
				 document:(MBDocument *)document
			   dialogName:(NSString*) dialogName;

-(BOOL) isPreConditionValid;

@end