//
//  TappableScrollView.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TappableScrollView.h"


@implementation TappableScrollView

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	if (self.dragging)
		[super touchesEnded: touches withEvent: event];
	else
		[self.nextResponder touchesEnded: touches withEvent:event];
}

@end
