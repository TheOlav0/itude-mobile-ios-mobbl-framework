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

#import "MBViewBuilder.h"
#import "MBViewBuilderFactory.h"
#import "MBComponent.h"
#import "MBStyleHandler.h"

#import "MBPanel.h"
#import "MBForEach.h"

@implementation MBViewBuilder

-(MBStyleHandler*) styleHandler {
	return [[MBViewBuilderFactory sharedInstance] styleHandler];	
}

-(CGRect) buildChildren:(NSArray*) children 
				forView:(UIView*) view 
	   horizontalLayout:(BOOL) horizontalLayout
				 bounds:(CGRect) maxBounds 
			  viewState:(MBViewState) viewState {

	if([children count] == 0) return maxBounds;
	
	CGFloat xOffset = 0;
	CGFloat yOffset = 0;
	CGFloat width = maxBounds.size.width / [children count];

	for(MBComponent *child in children) {
		
		[[self styleHandler] applyInsetsForComponent:child];
		int insetLeft = child.leftInset;
		int insetTop = child.topInset;
		int insetRight = child.rightInset;
		int insetBottom = child.bottomInset;
		
		CGRect maxChildBounds = maxBounds;
		maxChildBounds.size.width -= insetLeft + insetRight;
		maxChildBounds.size.height -= insetTop + insetBottom;
        
        UIView *childView = nil;
        
        if ([child isKindOfClass:[MBPanel class]]) {
            childView = [[MBViewBuilderFactory sharedInstance].panelViewBuilderFactory buildPanelView:(MBPanel *)child forParent:view withMaxBounds:maxChildBounds viewState:viewState];
        }
            
		if(childView)
		{
			xOffset += insetLeft;
			yOffset += insetTop;
			CGRect frame = childView.frame;
			frame.origin.x = xOffset;
			frame.origin.y = yOffset; 
			
			if(horizontalLayout) frame.size.width = width;
			
			frame.size.width -= insetLeft + insetRight;
			frame.size.height -= insetTop + insetBottom;
			
			childView.frame = frame;
            if (!childView.superview)			[view addSubview:childView];
			
			if(horizontalLayout) {
				xOffset += childView.frame.size.width;
				maxBounds.size.width = MAX(maxBounds.size.width - frame.size.width, 0);
			}
			else {
				yOffset += childView.frame.size.height;
				maxBounds.size.height = MAX(maxBounds.size.height - frame.size.height, 0);
			}
		}
	}
	
	// return the height that is left over in maxbounds
	return maxBounds;
}

-(void) adjustBoundsForView:(UIView*) view maxBounds:(CGRect) maxBounds boundsLeftOver:(CGRect) boundsLeftOver {
	view.bounds = CGRectMake(0, 0, boundsLeftOver.size.width, maxBounds.size.height - boundsLeftOver.size.height);
}

@end
