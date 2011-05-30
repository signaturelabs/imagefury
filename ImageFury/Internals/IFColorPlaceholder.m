/*
 ``The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/
 
 The Initial Developer of the Original Code is Hollrr, LLC.
 Portions created by the Initial Developer are Copyright (C) 2011
 the Initial Developer. All Rights Reserved.
 
 Contributor(s):
 
 Traun Leyden <tleyden@signature-app.com>
 
 */

#import "IFColorPlaceholder.h"


@implementation IFColorPlaceholder

@synthesize color;

- (id)initWithColor:(UIColor *)col {

	if (self = [super init]) {
		self.color = col;
	}
	
	return self;
	
	
}

- (UIView*)getPlaceholderGraphic:(UIView *)graphic {
	
	if(!graphic) {
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		graphic = [[[UIView alloc] init] autorelease];
		
		graphic.frame = frame;
		
		graphic.backgroundColor = color;
	}
	
	return graphic;
}

- (UIView*)getLoadingIndicator:(UIView *)oldLoadingIndicator progress:(NSNumber *)progress {
	
	return nil;
}

- (void)dealloc {

	self.color = nil;
	[super dealloc];
	
}



@end
