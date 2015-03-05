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

#import "MBConditionalPage.h"
#import "MBSession.h"

@implementation MBConditionalPage

@synthesize definitionWhenTrue = _definitionWhenTrue;
@synthesize definitionWhenFalse = _definitionWhenFalse;

- (instancetype)initWithDefinitionWhenTrue:(MBPageDefinition*)definitionWhenTrue
                   WithDefinitionWhenFalse:(MBPageDefinition*)definitionWhenFalse
                        withViewController:(UIViewController<MBViewControllerProtocol>*)viewController
                                  document:(MBDocument*)document
                                  rootPath:(NSString*)rootPath
                                 viewState:(MBViewState)viewState
{
	MBPageDefinition *def = ([MBSession sharedInstance].loggedOn) ? definitionWhenTrue
                                                                  : definitionWhenFalse;
	
    self = [super initWithDefinition:def withViewController:viewController document:document rootPath:rootPath viewState:viewState];
	if (self) {
		self.definitionWhenTrue = definitionWhenTrue;
		self.definitionWhenFalse = definitionWhenFalse;
        self.pageName = definitionWhenTrue.name;
	}
	return self;
}

- (instancetype)initWithDefinitionWhenTrue:(MBPageDefinition*)definitionWhenTrue
                   WithDefinitionWhenFalse:(MBPageDefinition*)definitionWhenFalse
                                  document:(MBDocument*)document
                                  rootPath:(NSString*)rootPath
                                 viewState:(MBViewState)viewState
                             withMaxBounds:(CGRect)bounds
{
	MBPageDefinition *def = ([MBSession sharedInstance].loggedOn) ? definitionWhenTrue
                                                                  : definitionWhenFalse;
    
    self = [super initWithDefinition:def document:document rootPath:rootPath viewState:viewState withMaxBounds:bounds];
    if (self)  {
		self.definitionWhenTrue = definitionWhenTrue;
		self.definitionWhenFalse = definitionWhenFalse;
        self.pageName = definitionWhenTrue.name;
	}
	return self;
}

- (void)dealloc
{
    self.definitionWhenTrue = nil;
    self.definitionWhenFalse = nil;
	[super dealloc];
}

- (void)rebuild
{
	self.definition = ([MBSession sharedInstance].loggedOn) ? self.definitionWhenTrue
                                                            : self.definitionWhenFalse;
	[super rebuild];
}

@end
