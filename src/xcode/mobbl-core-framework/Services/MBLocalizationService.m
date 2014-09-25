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
#import "MBLocalizationService.h"
#import "MBResourceService.h"
#import "MBProperties.h"

static MBLocalizationService *_instance = nil;
static NSString *_localeCode = nil;

@implementation MBLocalizationService

@synthesize currentLanguage = _currentLanguage;

+(MBLocalizationService *) sharedInstance {
	@synchronized(self) {
		if(_instance == nil) {
			_instance = [[self alloc] init];
		}
	}
	return _instance;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		_languages = [[NSMutableDictionary new] retain];
		
        // Determine the application language (depending on the property in the applicationproperties.xmlx)
		NSString *storedLanguage = [MBProperties valueForProperty:PROPERTY_LANGUAGE];
		if (storedLanguage) {
			self.currentLanguage = storedLanguage;
		}
		else {
			// TODO: Use phone default
			self.currentLanguage = @"nl"; // Set dutch as default
		}
        
	}
	return self;
}

- (void) dealloc
{
	[_languages release];
	[_currentDictionary release];
	[_currentLanguage release];
	[super dealloc];
}

-(NSMutableDictionary*) bundleForCode:(NSString*) languageCode {
	NSMutableDictionary *result = [[NSMutableDictionary new] autorelease];
	for(NSMutableDictionary *bundle in [[MBResourceService sharedInstance] bundlesForLanguageCode:languageCode]) {
		[result addEntriesFromDictionary:bundle];
	}
	return result;
}

-(NSMutableDictionary*) languageForCode:(NSString*) languageCode {
	NSMutableDictionary *result = nil;
	@synchronized(_languages) {
		result = [_languages valueForKey:languageCode];
		if(result == nil) {
			result = [self bundleForCode: languageCode];
			[_languages setValue:result forKey:languageCode];
		}
	}
	return result;
}

-(void) setCurrentLanguage:(NSString*) code {
    if (![_currentLanguage isEqualToString:code]) {
        [_currentLanguage release];
        _currentLanguage = [code retain];
	
        // Keep a local reference to the currentDictionary for optimization because getting the dictionary for it every time a translation is requested, is verry, verry costly
        _currentDictionary = [self languageForCode:code];
    }
}

-(NSString*) textForKey:(NSString*) key {
	return [self textForKey:key logWarnings:NO];
}

-(NSString*) textForKey:(NSString*) key logWarnings:(BOOL)logWarnings {
	if(key == nil) return nil;
	BOOL found = NO;
	NSString* text = key;
    for (NSString *keyString in [_currentDictionary allKeys]) {
        if ([keyString isEqualToString:key]) {
            text = [_currentDictionary valueForKey:key];
            found = YES;
        }
    }
	if(!found) {
		// NOTE for optimization: This log is printed only in a debug build (not in release build). Logging to the console is verry costly! Keep that in minde when optimizing code!
		if (logWarnings) {
			WLog(@"Warning: no translation defined for key '%@' using languageCode=%@", key, self.currentLanguage);
		}
	}
	return text;
}

// NOTE: Calling this method a lot decreases performance drasticly. Be aware of this
-(NSString*) textForKey:(NSString*) key forLanguageCode:(NSString *)languageCode logWarnings:(BOOL)logWarnings {
	if(key == nil) return nil;
	
    NSMutableDictionary *keys = [self languageForCode:languageCode];
	NSString* text = [keys valueForKey:key];
	if(text == nil) {
		// NOTE for optimization: This log is printed only in a debug build (not in release build). Logging to the console is verry costly! Keep that in minde when optimizing code!
		if (logWarnings) {
            WLog(@"Warning: no translation defined for key '%@' using languageCode=%@", key, self.currentLanguage ? self.currentLanguage : @"");
		}
		text = key;
	}
	return text;
}

-(NSString*) textForKey:(NSString*) key withArguments:(id) argument, ...
{
	if(key == nil) return nil;

	NSMutableString *mask = [NSMutableString stringWithString:[self textForKey: key]];
	
	for(int i=1; i<=5; i++) {
		NSString *from = [NSString stringWithFormat:@"${%i}", i];
		NSString *to = [NSString stringWithFormat:@"%%%i$@", i];
		
		[mask replaceOccurrencesOfString:from withString:to options:NSLiteralSearch range:NSMakeRange(0, [mask length])];
	}
	
	NSMutableArray *args = [NSMutableArray array];
	
	id eachObject = nil;
	va_list argumentList;
	if (argument)                      // The first argument isn't part of the varargs list,
	{                                   // so we'll handle it separately.
		[args addObject: argument];
		va_start(argumentList, argument);          // Start scanning for arguments after argument.
		while ((eachObject = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
			[args addObject: eachObject];             // that isn't nil, add it to self's contents.
		va_end(argumentList);
	}
	
	// WR: For a more elegant solution to unpacking the variable arguments or just passing them on: let me know!
	if([args count] ==0) return mask;
	if([args count] ==1) return [NSString stringWithFormat:mask, [args objectAtIndex:0]];
	if([args count] ==2) return [NSString stringWithFormat:mask, [args objectAtIndex:0], [args objectAtIndex:1]];
	if([args count] ==3) return [NSString stringWithFormat:mask, [args objectAtIndex:0], [args objectAtIndex:1], [args objectAtIndex:2]];
	if([args count] ==4) return [NSString stringWithFormat:mask, [args objectAtIndex:0], [args objectAtIndex:1], [args objectAtIndex:2], [args objectAtIndex:3]];
	if([args count] ==5) return [NSString stringWithFormat:mask, [args objectAtIndex:0], [args objectAtIndex:1], [args objectAtIndex:2], [args objectAtIndex:3], [args objectAtIndex:4]];
	
	return [NSString stringWithFormat:@"Invalid number of arguments in mask with key='%@'", key];
}

-(NSString*) localeCode {
	if(_localeCode == nil) {
	_localeCode = [MBProperties valueForProperty:@"localeCode"];
		if(_localeCode == nil) _localeCode = [[NSLocale currentLocale] localeCode];//@"nl_NL";
	}
	return _localeCode;
}

@end
