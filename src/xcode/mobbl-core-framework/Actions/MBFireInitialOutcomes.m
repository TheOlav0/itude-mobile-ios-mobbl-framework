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

#import "MBFireInitialOutcomes.h"
#import "MBOutcome.h"
#import "MBDocument.h"
#import "MBDataManagerService.h"
#import "MBApplicationController.h"

@implementation MBFireInitialOutcomes

-(NSString *)documentName {
    return @"InitialOutcomes";
}

- (void)handleInitialOutcomes {
	MBDocument *initialOutcomes = [[MBDataManagerService sharedInstance] loadDocument:[self documentName]];
	for(MBElement *element in [[initialOutcomes valueForPath:@"/Outcome"] reverseObjectEnumerator]) {
        MBOutcome *outcome = [self outcomeForElement:element];

		[self handleOutcomeOnMainThread:outcome];
	}
}

// Make sure the first tab is selected
- (void)activateFirstPageStack {
    MBDocument *initialOutcomes = [[MBDataManagerService sharedInstance] loadDocument:[self documentName]];
    MBElement *element = [initialOutcomes valueForPath:@"/Outcome[0]"];
    MBOutcome *outcome = [self outcomeForElement:element];
    [self activatePageStackWithName:outcome.pageStackName];
}

-(void) handleOutcomeOnMainThread:(MBOutcome*) outcome {
    outcome.noBackgroundProcessing = YES;
	[[MBApplicationController currentInstance] handleOutcome:outcome];
}

-(void) activatePageStackWithName:(NSString*) name {
    [[MBApplicationController currentInstance] activatePageStackWithName:name];
}


#pragma mark -
#pragma mark MBAction protocol

-(MBOutcome*) execute:(MBDocument *)document withPath:(NSString *)path {
    [self handleInitialOutcomes];
    
    // Make sure the first tab is selected
    [self activateFirstPageStack];
	return nil;
}


#pragma mark -
#pragma mark Util

- (MBOutcome *)outcomeForElement:(MBElement *)element {
    MBOutcome *oc = [[[MBOutcome alloc] init] autorelease];
    oc.outcomeName = [element valueForAttribute:@"action"];
    oc.pageStackName = [element valueForAttribute:@"pageStack"];
    
    // For backwards compatibility
    if (oc.pageStackName.length == 0) {
        oc.pageStackName = [element valueForPath:@"@dialog"];
    }
    
    oc.noBackgroundProcessing = TRUE;
    oc.transferDocument = FALSE;
    
    return oc;
}

@end
