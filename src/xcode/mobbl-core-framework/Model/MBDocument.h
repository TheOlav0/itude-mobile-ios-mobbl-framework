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

#import "MBElement.h"
#import "MBElementContainer.h"
#import "MBDocumentDefinition.h"

/** XML-like structure containing application data.
 
 This is a generic data structure containing application data. Its structure
 is made specific by a MBDocumentDefinition. Any data that is contained in MBDocuments can be drag'n'drop' ported to other platforms.
 The document definition is specified in the application configuration file which is typically named config.xmlx file. If config.xmlx becomes large, the configuration is often split into a bunch of file which are references using an <Include .../> statement in config.xmlx.
 MBDocuments are retrieved and stored using the MBDataManagerService. The document definition specifies where an MBDocument should be retrieved from (Webservice, Filesystem etc) and whether new MBDocuments should be auto-created.
 Once a definition is in place (in the application configuration file) an MBDocument can be created in code using the MBMetadataService. 
 
 */
@interface MBDocument : MBElementContainer {
	MBDocumentDefinition *_definition;
	NSMutableDictionary *_sharedContext;
	NSMutableDictionary *_pathCache;

@private
	
	// Stores the document that was used as an argument when this document was loaded
	// Needed to be able to reload the document (using the same arguments)
	MBDocument *_argumentsUsed;
}

/// @name Properties
@property (nonatomic, retain) NSMutableDictionary *sharedContext;
@property (nonatomic, retain) MBDocument *argumentsUsed;

/// @name Creating a Document
/** Creates and returns an empty Document conforming to the given MBDocumentDefinition. */
- (id) initWithDocumentDefinition: (MBDocumentDefinition*) definition;
- (void) assignToDocument:(MBDocument*) target;

- (BOOL)isEqualToDocument:(MBDocument *)document;

/** Loads a fresh copy of this document using the registered DataHandler. 
 
 See [MBDataManagerService loadFreshDocument:withArguments:forDelegate:resultSelector:errorSelector:]
 */
- (void) loadFreshCopyForDelegate:(id) delegate resultSelector:(SEL) resultSelector errorSelector:(SEL)errorSelector;
- (void) reload;

/// @name Managing document cache
- (void) clearPathCache;
- (void) clearAllCaches;

/// @name Exporting XML
/** Returns an XML representation of the Document. 
 @param level starting level of the XML representation, use 0 to start with root element.
 */
- (NSString *) asXmlWithLevel:(int)level;

@end
