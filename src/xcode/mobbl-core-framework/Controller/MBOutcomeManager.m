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

//  MBOutcomeManager.m
//  mobbl-core-framework
//
//  Created by Pjotter Tommassen on 2013/29/11.

#import "MBOutcomeManager.h"
#import "MBApplicationController.h"
#import "MBOutcomeListenerProtocol.h"
#import "MBOutcome.h"
#import "MBMetadataService.h"
#import "MBDataManagerService.h"
#import "MBViewManager.h"
#import "MBViewBuilderFactory.h"
#import "MBPage.h"
#import "MBAlertController.h"
#import "MBMacros.h"
#import <CoreFoundation/CoreFoundation.h>


#ifdef DEBUG
#define THREAD_DUMP(n) CFAbsoluteTime time = CFAbsoluteTimeGetCurrent (); const char *method = n; NSLog(@"Method: %s Thread: %s Queue: %s", n, [[NSThread currentThread] isMainThread] ? "main" : "other", dispatch_queue_get_label (dispatch_get_current_queue ()));

#define THREAD_RELEASE NSLog (@"Leaving %s Time: %f", method, (CFAbsoluteTimeGetCurrent () - time));
#else
#define THREAD_DUMP(n)
#define THREAD_RELEASE
#endif

typedef enum {
    Initializing = 0,
    InformListenersStart,
    Persist,
    GatherOutcomes,
    DialogChanges,
    Action,
    PreparePage,
    ShowPage,
    Alert,
    InformDone,
    
    Done,
} OutcomePhase;

typedef struct {
    OutcomePhase phase;
    MBOutcome *outcome;
    MBOutcomeManager *manager;
    NSArray *outcomesToProcess;
    BOOL error;
    NSArray *documents;
    NSArray *pageDefinitions;
    dispatch_semaphore_t latch;
} OutcomeState;


@interface MBOutcomeManager ()
@property (nonatomic, retain) NSMutableArray *outcomeListeners;
@property (nonatomic, assign, readonly) dispatch_queue_t queue;

@end

@implementation MBOutcomeManager


- (id) init
{
	self = [super init];
	if (self != nil) {
		_outcomeListeners = [[NSMutableArray array] retain];
		_queue = dispatch_queue_create("com.itude.mobbl.OutcomeQueue", DISPATCH_QUEUE_CONCURRENT);
	}
	return self;
}


-(void) dealloc {
	dispatch_release(_queue);
	[_outcomeListeners release];
	[super dealloc];
}



-(void) handleOutcome:(MBOutcome *)outcome {
	THREAD_DUMP("handleOutcome")

	@try {
        if ([self shouldHandleOutcome:outcome]) {
            [self doHandleOutcome: outcome];
        }
	}
	@catch (NSException *e) {
		[[MBApplicationController currentInstance] handleException: e outcome: outcome];
	};

	THREAD_RELEASE
}

- (BOOL)shouldHandleOutcome:(MBOutcome *)outcome {
    // Ask all outcome listeners if the outcome should be handled
    for(id<MBOutcomeListenerProtocol> lsnr in self.outcomeListeners) {
        if ([lsnr respondsToSelector:@selector(shouldHandleOutcome:)]) {
            BOOL shouldHandleOutcome = [lsnr shouldHandleOutcome:outcome];
            if (!shouldHandleOutcome) {
                return FALSE;
            }
        }
    }
    
    return TRUE;
}


void dispatchOutcomePhase(dispatch_queue_t queue, OutcomeState inState, void (^block)(OutcomeState *state)) {
    if ([inState.outcome noBackgroundProcessing]) {
        @autoreleasepool {
            __block OutcomeState state = inState;
            @try {
                block (&state);
            }
            @catch (NSException *e) {
                state.error = YES;
                [[MBApplicationController currentInstance] handleException: e outcome: state.outcome];
            }
            @finally {
                [state.manager finishedPhase:state];
            }
        }
    } else {
        dispatch_async(queue, ^{
            @autoreleasepool {
                __block OutcomeState state = inState;
                @try {
                    block (&state);
                }
                @catch (NSException *e) {
                    state.error = YES;
                    [[MBApplicationController currentInstance] handleException: e outcome: state.outcome];
                }
                @finally {
                    [state.manager finishedPhase:state];
                }
            }
        });
    }
    
}

- (void) doHandleOutcome:(MBOutcome *)outcome {
    DLog(@"MBApplicationController:handleOutcome: %@", outcome);
    
    OutcomeState state;
    state.phase = Initializing;
    state.outcome = [outcome retain];
    state.manager = self;
    state.outcomesToProcess = nil;
    state.error = NO;
    state.documents = nil;
    state.pageDefinitions = nil;
    state.latch = dispatch_semaphore_create(0);
    [self finishedPhase:state];
    
    if ([outcome noBackgroundProcessing]) {
        dispatch_semaphore_wait(state.latch, DISPATCH_TIME_FOREVER);
    }
    
    dispatch_release (state.latch);
    
}

- (void) finishedPhase:(OutcomeState) state {
    
    if (state.error) goto releaseState;
    
    state.phase++;

    switch (state.phase) {
        case Initializing: // ?
        case InformListenersStart:
            [self informListenersDone:state];
            break;
        case Persist:
            [self persist:state];
            break;
        case GatherOutcomes:
            [self gatherOutcomes:state];
            break;
        case DialogChanges:
            [self dialogChanges:state];
            break;
        case Action:
            [self action:state];
            break;
        case PreparePage:
            [self preparePage:state];
            break;
        case ShowPage:
            [self showPages:state];
            break;
        case Alert:
            [self alert:state];
            break;
        case InformDone:
            [self informListenersDone:state];
            break;
        case Done:
            goto releaseState;
    }
    
    return;
    
releaseState:
    [state.outcome release];
    [state.outcomesToProcess release];
    [state.documents release];
    [state.pageDefinitions release];
    dispatch_semaphore_signal(state.latch);
}



- (void) informListenersStart:(OutcomeState) state {
    dispatchOutcomePhase (self.queue, state, ^(OutcomeState *state) {
            // notify all outcome listeners
            for(id<MBOutcomeListenerProtocol> lsnr in self.outcomeListeners) {
                if ([lsnr respondsToSelector:@selector(outcomeProduced:)])
                    [lsnr outcomeProduced:state->outcome];
            }
    });
}

-(void) persist:(OutcomeState) state {
    dispatchOutcomePhase(self.queue, state, ^(OutcomeState *state){
        MBOutcome *outcome = state->outcome;
        // Make sure that the (external) document cache of the document itself is cleared since this
        // might interfere with the preconditions that are evaluated later on. Also: if the document is transferred
        // the next page / action will also have fresh copies
        [outcome.document clearAllCaches];
        
        MBMetadataService *metadataService = [MBMetadataService sharedInstance];
        
        NSArray *outcomeDefinitions = [metadataService outcomeDefinitionsForOrigin:outcome.originName outcomeName:outcome.outcomeName throwIfInvalid:FALSE];
        if([outcomeDefinitions count] == 0) {
            NSString *msg = [NSString stringWithFormat:@"No outcome defined for origin=%@ outcome=%@", outcome.originName, outcome.outcomeName];
            @throw [NSException exceptionWithName:@"NoOutcomesDefined" reason:msg userInfo:nil];
        }
        
        BOOL shouldPersist = FALSE;
        for(MBOutcomeDefinition *outcomeDef in outcomeDefinitions) {
            shouldPersist |= outcomeDef.persist;
        }
        
        if(shouldPersist) {
            if([outcome document] == nil) {
                DLog(@"WARNING: origin=%@ and name=%@ has persistDocument=TRUE but there is no document (probably the outcome originates from an action; which cannot have a document)", outcome.originName, outcome.outcomeName);
            }
            else [[MBDataManagerService sharedInstance] storeDocument: outcome.document];
        }
    });
}

-(void) gatherOutcomes:(OutcomeState) state {
    dispatchOutcomePhase(self.queue, state, ^(OutcomeState *state){
        NSMutableArray *toProcess = [NSMutableArray new];
        MBOutcome *outcome = state->outcome;
        
        MBMetadataService *metadataService = [MBMetadataService sharedInstance];
        NSArray *outcomeDefinitions = [metadataService outcomeDefinitionsForOrigin:outcome.originName outcomeName:outcome.outcomeName throwIfInvalid:FALSE];

        for(MBOutcomeDefinition *outcomeDef in outcomeDefinitions) {
            
            if([@"RESET_CONTROLLER" isEqualToString:outcomeDef.action]) {
                [[MBApplicationController currentInstance] resetController];
            }
            else {
                
                // Create a working copy of the outcome; we manipulate the outcome below and we want the passed outcome to be left unchanged (good practise)
                MBOutcome *outcomeToProcess = [[[MBOutcome alloc] initWithOutcomeDefinition: outcomeDef] autorelease];
                
                outcomeToProcess.path = outcome.path;
                outcomeToProcess.document = outcome.document;
                if (outcomeToProcess.pageStackName.length == 0) outcomeToProcess.pageStackName = outcome.pageStackName;
                if (outcomeToProcess.pageStackName.length == 0) outcomeToProcess.pageStackName = outcome.originPageStackName;
                if (outcome.displayMode != nil) outcomeToProcess.displayMode = outcome.displayMode;
                outcomeToProcess.noBackgroundProcessing = outcome.noBackgroundProcessing || outcomeDef.noBackgroundProcessing;
                
                if([outcomeToProcess isPreConditionValid]) [toProcess addObject:outcomeToProcess];
            }
        }
        
        state->outcomesToProcess = toProcess;
     });
}


- (void) dialogChanges:(OutcomeState) state {
    
    dispatchOutcomePhase(dispatch_get_main_queue(), state, ^(OutcomeState *state){
        for (MBOutcome *outcomeToProcess in state->outcomesToProcess) {
            if([@"ENDMODAL" isEqualToString: outcomeToProcess.displayMode]) {
                MBDialogController *dialog = [[MBApplicationController currentInstance].viewManager.dialogManager dialogForPageStackName:outcomeToProcess.pageStackName];
                [[[MBViewBuilderFactory sharedInstance] dialogDecoratorFactory] dismissDialog:dialog withTransitionStyle:outcomeToProcess.transitionStyle];
            }
            
            else if([@"POP" isEqualToString: outcomeToProcess.displayMode]) {
                // TODO: This causes a bug when the user desides to pop the rootViewController
                [[MBApplicationController currentInstance].viewManager.dialogManager popPageOnPageStackWithName: outcomeToProcess.pageStackName];
            }
            else if([@"POPALL" isEqualToString: outcomeToProcess.displayMode]) {
                [[MBApplicationController currentInstance].viewManager.dialogManager endPageStackWithName: outcomeToProcess.pageStackName keepPosition:TRUE];
            }
            else if([@"CLEAR" isEqualToString: outcomeToProcess.displayMode]) {
                [[MBApplicationController currentInstance].viewManager resetView];
            }
            else if([@"END" isEqualToString: outcomeToProcess.displayMode]) {
                [[MBApplicationController currentInstance].viewManager.dialogManager endPageStackWithName: outcomeToProcess.pageStackName keepPosition: FALSE];
            }
        }
    });
}

-(void) action:(OutcomeState) state
{
    dispatchOutcomePhase(self.queue, state, ^(OutcomeState *state) {
        for (MBOutcome *outcomeToProcess in state->outcomesToProcess) {
            MBMetadataService *metadataService = [MBMetadataService sharedInstance];
            MBActionDefinition *actionDef = [metadataService definitionForActionName:outcomeToProcess.action throwIfInvalid: FALSE];
            if(actionDef != nil) {
                if(!outcomeToProcess.noBackgroundProcessing)
                    [[MBApplicationController currentInstance].viewManager showActivityIndicatorWithMessage:outcomeToProcess.processingMessage];
                
                [self performActionInBackground:[NSArray arrayWithObjects:[[[MBOutcome alloc] initWithOutcome:outcomeToProcess] autorelease], actionDef,  nil]];
            }
        }
    });
}

-(void) preparePage:(OutcomeState) state {
    dispatchOutcomePhase(self.queue, state, ^(OutcomeState *state) {
        NSMutableArray *documents = [NSMutableArray new];
        NSMutableArray *pageDefinitions = [NSMutableArray new];
        for (MBOutcome *causingOutcome in state->outcomesToProcess) {
            
            MBMetadataService *metadataService = [MBMetadataService sharedInstance];
            MBPageDefinition *pageDef = [metadataService definitionForPageName:causingOutcome.action throwIfInvalid: FALSE];
            
            if(pageDef != nil) {
                if(!causingOutcome.noBackgroundProcessing)
                    [[MBApplicationController currentInstance].viewManager showActivityIndicatorWithMessage:causingOutcome.processingMessage];
                
                NSString *pageName = pageDef.name;
                
                // construct the page
                MBPageDefinition *pageDefinition = [[MBMetadataService sharedInstance] definitionForPageName:pageName];
                
                // Load the document from the store
                MBDocument *document = nil;
                
                if(causingOutcome.transferDocument) {
                    if(causingOutcome.document == nil)  {
                        NSString *msg = [NSString stringWithFormat:@"No document provided (nil) in outcome '%@' by action/page '%@' but transferDocument='TRUE' in outcome definition",causingOutcome.outcomeName , causingOutcome.originName];
                        @throw [NSException exceptionWithName:@"InvalidOutcome" reason:msg userInfo:nil];
                    }
                    
                    NSString *actualType =  [[causingOutcome.document definition] name];
                    if(![actualType isEqualToString: [pageDefinition documentName]]) {
                        NSString *msg = [NSString stringWithFormat:@"Document provided via outcome by action/page=%@ (transferDocument='TRUE') is of type %@ but must be of type %@",
                                         causingOutcome.originName, actualType, [pageDefinition documentName]];
                        @throw [NSException exceptionWithName:@"InvalidOutcome" reason:msg userInfo:nil];
                    }
                    
                    document = causingOutcome.document;
                } else {
                    document = [[MBDataManagerService sharedInstance] loadDocument:[pageDefinition documentName]];
                    
                    if(document == nil) {
                        document = [[MBDataManagerService sharedInstance] loadDocument:[pageDefinition documentName]];
                        NSString *msg = [NSString stringWithFormat:@"Document with name %@ not found (check filesystem/webservice)", [pageDefinition documentName]];
                        @throw [NSException exceptionWithName:@"NoDocument" reason:msg userInfo:nil];
                    }
                }
                
                [documents addObject:document];
                [pageDefinitions addObject:pageDefinition];
            }
            else {
                [documents addObject:[NSNull null]];
                [pageDefinitions addObject:[NSNull null]];

            }

        }
        
        
        state->documents = documents;
        state->pageDefinitions = pageDefinitions;
    });
}


-(void) showPages:(OutcomeState) state {
    dispatchOutcomePhase(dispatch_get_main_queue(), state, ^(OutcomeState *state) {
        for (int i=0; i < [state->outcomesToProcess count]; ++i) {
            MBOutcome *causingOutcome = [state->outcomesToProcess objectAtIndex:i];
            MBDocument *document = [state->documents objectAtIndex:i];
            MBPageDefinition *pageDefinition = [state->pageDefinitions objectAtIndex:i];
            
            if (pageDefinition != [NSNull null]) {
            
                [[MBApplicationController currentInstance].viewManager hideActivityIndicator];
                NSString *displayMode = causingOutcome.displayMode;
                NSString *transitionStyle = causingOutcome.transitionStyle;
                MBViewState viewState = [[MBApplicationController currentInstance].viewManager currentViewState];
                
                CGRect bounds = [MBApplicationController currentInstance].viewManager.bounds;
                
                MBPage *page = [[MBApplicationController currentInstance].applicationFactory createPage:pageDefinition
                                                                                               document: document
                                                                                               rootPath: causingOutcome.path
                                                                                              viewState: viewState
                                                                                          withMaxBounds: bounds];
                page.applicationController = [MBApplicationController currentInstance];
                page.pageStackName = causingOutcome.pageStackName;
                
                [[MBApplicationController currentInstance].viewManager showPage: page displayMode: displayMode transitionStyle: transitionStyle];
            }
        }
    });
}


-(void) alert:(OutcomeState) state
{
    dispatchOutcomePhase(self.queue, state, ^(OutcomeState *state) {
        for (MBOutcome *outcomeToProcess in state->outcomesToProcess) {
            MBMetadataService *metadataService = [MBMetadataService sharedInstance];

            MBAlertDefinition *alertDef = [metadataService definitionForAlertName:outcomeToProcess.action throwIfInvalid:FALSE];
            if (alertDef != nil) {
                [[MBApplicationController currentInstance].alertController handleAlert:alertDef forOutcome:outcomeToProcess];
            }
        }
    });
}


-(void) informListenersDone:(OutcomeState) state {
    dispatchOutcomePhase(dispatch_get_main_queue(), state, ^(OutcomeState *state) {
        for(id<MBOutcomeListenerProtocol> lsnr in self.outcomeListeners) {
            if ([lsnr respondsToSelector:@selector(outcomeHandled:)])
                [lsnr outcomeHandled:state->outcome];
        }

    });
}

//////// ACTION HANDLING

- (void) performActionInBackground:(NSArray *)args {
	THREAD_DUMP("performActionInBackground")

    MBOutcome *causingOutcome = [args objectAtIndex:0];

	@autoreleasepool {
		@try {

			MBActionDefinition *actionDef = [args objectAtIndex:1];
			id<MBAction> action = [[MBApplicationController currentInstance].applicationFactory createAction: actionDef.className];
			MBOutcome *actionOutcome = [action execute: causingOutcome.document withPath:causingOutcome.path];

			if(actionOutcome == nil) {
				[[MBApplicationController currentInstance].viewManager hideActivityIndicator];
				DLog(@"No outcome produced by action %@ (outcome == nil); no further procesing.", actionDef.name);
			}
			else {
				[self handleActionResult:[NSArray arrayWithObjects:causingOutcome, actionDef, actionOutcome, nil]];
			}
		}
		@catch (NSException *e) {
			[[MBApplicationController currentInstance] handleException: e outcome: causingOutcome];
		}
	}
	THREAD_RELEASE
}

- (void) handleActionResult:(NSArray *)args {
	THREAD_DUMP("handleActionResult")

    MBOutcome *causingOutcome = [args objectAtIndex:0];

    @try {
		[[MBApplicationController currentInstance].viewManager hideActivityIndicator];

        MBActionDefinition *actionDef = [args objectAtIndex:1];
        MBOutcome *actionOutcome = [args objectAtIndex:2];

        if(actionOutcome.pageStackName == nil) actionOutcome.pageStackName = causingOutcome.pageStackName;
        actionOutcome.originName = actionDef.name;

        [self handleOutcome:actionOutcome];
    }
    @catch (NSException *e) {
        [[MBApplicationController currentInstance] handleException: e outcome: causingOutcome];
    }
	THREAD_RELEASE
}



#pragma mark -
#pragma mark Outcome listeners

- (void) registerOutcomeListener:(id<MBOutcomeListenerProtocol>) listener {
	if(![self.outcomeListeners containsObject:listener]) [self.outcomeListeners addObject:listener];
}

- (void) unregisterOutcomeListener:(id<MBOutcomeListenerProtocol>) listener {
	[self.outcomeListeners removeObject: listener];
}


@end