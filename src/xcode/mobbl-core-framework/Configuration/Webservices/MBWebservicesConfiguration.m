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

#import "MBWebservicesConfiguration.h"

@implementation MBWebservicesConfiguration

- (id) init
{
	self = [super init];
	if (self != nil) {
		_endPoints = [NSMutableDictionary new];
        _resultListeners = [NSMutableArray new];
        _eraseDocumentFromCacheOnError = YES;
	}
	return self;
}

- (void) dealloc
{
	[_endPoints release];
    [_resultListeners release];
	[super dealloc];
}

- (void) linkGlobalListeners {
    for(MBEndPointDefinition *def in [_endPoints allValues]) {
        [[def resultListeners] addObjectsFromArray: _resultListeners];
    }
}

- (void) addEndPoint:(MBEndPointDefinition *)definition {
	[_endPoints setValue:definition forKey:definition.documentOut];
}

- (MBEndPointDefinition *)getEndPointForDocumentName:(NSString *)documentName {
	return (MBEndPointDefinition*)[_endPoints valueForKey:documentName];
}

- (void) addResultListener:(MBResultListenerDefinition*) lsnr {
    [_resultListeners addObject: lsnr];
}

- (NSMutableArray*) resultListeners {
    return _resultListeners;
}

@end
