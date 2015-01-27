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
#import "MBPage.h"
#import "MBOutcome.h"
#import "MBComponent.h"
#import "MBDefinition.h"
#import "MBForEachDefinition.h"
#import "MBForEach.h"
#import "MBOutcomeDefinition.h"
#import "MBMetadataService.h"
#import "MBViewBuilderFactory.h"
#import "MBPageViewBuilder.h"
#import "StringUtilities.h"
#import "MBViewControllerProtocol.h"
#import "MBComponentFactory.h"
#import "MBValueChangeListenerProtocol.h"
#import "MBSession.h"

#import "UIViewController+Layout.h"

@interface MBPage ()

@property (nonatomic, retain) NSMutableDictionary *valueChangedListeners;

@end

@implementation MBPage

@synthesize document = _document;

- (NSMutableDictionary *)valueChangedListeners
{
    if (!_valueChangedListeners) {
        _valueChangedListeners = [NSMutableDictionary dictionary];
    }
    return _valueChangedListeners;
}

- (NSMutableArray *)childViewControllers
{
    if (!_childViewControllers) {
        _childViewControllers = [[NSMutableArray alloc] init];
    }
    return _childViewControllers;
}

-(void) dealloc
{
	// Public properties
    self.pageName = nil;
    self.rootPath = nil;
    self.pageStackName = nil;
    self.dialogName = nil;
    self.childViewControllers = nil;
    self.documentDiff = nil;
    self.transitionStyle = nil;
    self.valueChangedListeners = nil;
    
    [_document release];
    [super dealloc];
}

- (instancetype)initWithDefinition:(MBPageDefinition*) definition
                withViewController:(UIViewController<MBViewControllerProtocol>*) viewController
                          document:(MBDocument*) document
                          rootPath:(NSString*) rootPath
                         viewState:(MBViewState) viewState
{
    // Make sure that the Panel does not start building the view based on the children OF THIS PAGE because that is too early
    // The children need the additional information that is set after the constructor of super. So pass buildViewStructure: FALSE
    // and build the children ourselves here
    self = [super initWithDefinition:definition document:document parent:nil buildViewStructure:NO];
	if (self) {
        self.definition = definition;
        self.rootPath = rootPath;
        self.pageName = definition.name;
		self.document = document;
        self.pageType = definition.pageType;
		self.viewState = viewState;
        self.maxBounds = [UIScreen mainScreen].applicationFrame;

		self.viewController = viewController;
		self.viewController.page = self;
		
		// Ok; now we can build the children:
        for(MBDefinition *def in definition.children) {
            if([def isPreConditionValid:document currentPath:self.absoluteDataPath]) {
                [self addChild:[MBComponentFactory componentFromDefinition:def document:document parent:self]];
            }
		}
	}
	return self;
}

- (instancetype)initWithDefinition:(MBPageDefinition*)definition
                          document:(MBDocument*) document
                          rootPath:(NSString*) rootPath
                         viewState:(MBViewState) viewState
                     withMaxBounds:(CGRect) bounds
{
    self = [self initWithDefinition:definition withViewController:nil document:document rootPath:rootPath viewState:viewState];
    if (self) {
        self.maxBounds = bounds;
        self.viewController = (UIViewController<MBViewControllerProtocol>*)[[MBApplicationFactory sharedInstance]createViewController:self];
        self.viewController.navigationItem.title = [self title];
        self.viewController.page = self;
        //[self rebuildView];
    }
	return self;
}


- (void)rebuild
{
	[self.document clearAllCaches];
	[super rebuild];
}

// This is a method required by component so any component can find the page
- (MBPage*)page
{
	return self;
}

- (void)hideKeyboard:(id)sender
{
	[self resignFirstResponder];
}

- (UIView*)buildViewWithMaxBounds:(CGRect)bounds forParent:(UIView*)parent viewState:(MBViewState)viewState
{
    if (self.viewController.isViewLoaded) {
        self.viewController.view = [[[UIView alloc] initWithFrame:bounds] autorelease];
    }
    [[MBViewBuilderFactory sharedInstance].pageViewBuilder rebuildPageView:self currentView:self.viewController.view withMaxBounds:bounds viewState:viewState];
    return self.viewController.view;
}

- (void)handleException:(NSException *)exception
{
	MBOutcome *outcome = [[MBOutcome alloc] initWithOutcomeName:self.pageName document:self.document];
	[self.applicationController handleException:exception outcome:outcome];
	[outcome release];
}

- (void)handleOutcome:(NSString *)outcomeName
{
	[self handleOutcome:outcomeName withPathArgument:nil];
}

- (void)handleOutcome:(NSString *)outcomeName withPathArgument:(NSString*)path
{
	MBOutcome *outcome = [[MBOutcome alloc] init];
	outcome.originName = self.pageName;
	outcome.outcomeName = outcomeName;
	outcome.document = self.document;
    outcome.pageStackName = self.pageStackName;
	outcome.path = path;

	[self.applicationController handleOutcome:outcome];
	[outcome release];
}

- (NSString *)componentDataPath
{
	return [self rootPath];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; pageID: %@>", [MBPage class], self, self.pageName];
}

- (void)setRootPath:(NSString *)path
{
	BOOL ignorePath = FALSE;
    
    if (!path) {
        path = @"";
    } else if (![path hasSuffix:@"/"]) {
        path = [NSString stringWithFormat:@"%@/", path];
    }
	
	if (path.length > 0) {
		MBPageDefinition* pd = (MBPageDefinition*)self.definition;
		NSString *stripped = [path stripCharacters:@"[]0123456789"].normalizedPath;
		
		// If the last character is not a slash (/), add one.
		if (![stripped hasSuffix:@"/"]) {
			stripped = [NSString stringWithFormat:@"%@/", stripped];
		}
		
		NSString *mustBe = pd.rootPath;
        if (!mustBe || [mustBe isEqualToString:@""]) {
            mustBe = @"/";
        }
        
		if (![stripped isEqualToString:mustBe]) {
			if ([mustBe isEqualToString:@"/"]) {
				WLog(@"Ignoring path %@ because the document definition used root path %@", stripped, mustBe);
				ignorePath = TRUE;
			} else {
				NSString *msg = [NSString stringWithFormat:@"Invalid root path %@->%@; does not conform to defined document root path %@ for page %@", path, stripped, mustBe, self.name];
				@throw [NSException exceptionWithName:@"InvalidPath" reason:msg userInfo:nil];
			}
		}
	}
	
    if(!ignorePath && _rootPath != path) {
        [_rootPath release];
        _rootPath = path;
        [_rootPath retain];
    }
}


- (UIView*)view
{
    return self.viewController.view;
}

- (void)unregisterAllViewControllers
{
	self.childViewControllers = nil;
}

- (void)registerViewController:(UIViewController*)controller
{
    if (![self.childViewControllers containsObject:controller]) {
        [self.childViewControllers addObject:controller];
    }
}

- (id)viewControllerOfType:(Class)clazz
{
	if(self.childViewControllers != nil) {
		for (UIViewController *ctrl in self.childViewControllers) {
			if ([ctrl isKindOfClass: clazz]) return ctrl;
		}
	}
	return nil;
}

- (NSString *)asXmlWithLevel:(int)level
{
	NSMutableString *result = [NSMutableString stringWithFormat: @"%*s<MBPage%@%@%@%@>\n", level, "",
							   [self attributeAsXml:@"pageName" withValue:self.name],
							   [self attributeAsXml:@"rootPath" withValue:self.rootPath],
							   [self attributeAsXml:@"dialogName" withValue:self.dialogName],
							   [self attributeAsXml:@"document" withValue:self.document.documentName]
							   ];
    
    [result appendString: [self childrenAsXmlWithLevel: level+2]];
	[result appendFormat:@"%*s</MBPage>\n", level, ""];
	
	return result;
}

- (MBDocumentDiff*)diffDocument:(MBDocument*)other
{
	MBDocumentDiff *diff = [[MBDocumentDiff alloc] initWithDocumentA:self.document andDocumentB:other];
	self.documentDiff = diff;
	[diff release];
	return self.documentDiff;
}

- (NSMutableArray*)listenersForPath:(NSString*)path
{
    if(![path hasPrefix:@"/"]) {
        path = [NSString stringWithFormat:@"/%@", path];
    }
	
	path = path.normalizedPath;
	NSMutableArray *lsnrList = [self.valueChangedListeners valueForKey:path];
	if (!lsnrList) {
		lsnrList = [NSMutableArray array];
		[self.valueChangedListeners setObject:lsnrList forKey:path];
	}
	return lsnrList;
}

- (void)registerValueChangeListener:(id<MBValueChangeListenerProtocol>)listener forPath:(NSString*)path
{
	// Check that the path is valid by reading the value:
	[self.document valueForPath:path];
	NSMutableArray *lsnrList = [self listenersForPath:path];
	[lsnrList addObject:listener];
}

- (void)unregisterValueChangeListener:(id<MBValueChangeListenerProtocol>)listener forPath:(NSString*)path
{
	// Check that the path is valid by reading the value:
	[self.document valueForPath:path];
	NSMutableArray *lsnrList = [self listenersForPath: path];
	[lsnrList removeObject:listener];
}

- (void)unregisterValueChangeListener:(id<MBValueChangeListenerProtocol>)listener
{
	// Check that the path is valid by reading the value:
    for(NSMutableArray *list in self.valueChangedListeners.allValues) {
        [list removeObject:listener];
    }
}

- (BOOL)notifyValueWillChange:(NSString*)value originalValue:(NSString*)originalValue forPath:(NSString*)path
{
	BOOL result = TRUE;
	NSMutableArray *lsnrList = [self listenersForPath:path];
	for(id lsnr in lsnrList) {
        if ([lsnr respondsToSelector:@selector(valueWillChange:originalValue:forPath:)]) {
			result &= [lsnr valueWillChange:value originalValue:originalValue forPath:path];
        }
	}
	return result;
}

- (void)notifyValueChanged:(NSString*)value originalValue:(NSString*)originalValue forPath:(NSString*)path
{
	NSMutableArray *lsnrList = [self listenersForPath:path];
	for(id lsnr in lsnrList) {
        if ([lsnr respondsToSelector:@selector(valueChanged:originalValue:forPath:)]) {
			[lsnr valueChanged:value originalValue:originalValue forPath:path];
        }
	}
}

- (MBViewState)currentViewState
{
	return self.viewState;
}

@end
