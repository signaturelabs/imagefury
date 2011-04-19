/*
 ``The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/
 
 The Initial Developer of the Original Code is Hollrr, LLC.
 Portions created by the Initial Developer are Copyright (C) 2011
 the Initial Developer. All Rights Reserved.
 
 Contributor(s):

 Dustin Dettmer <dusty@dustytech.com>
 Traun Leyden <tleyden@signature-app.com>
 
 */

#import "IFTextPlaceholder.h"

@interface IFTextPlaceholder ()

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIColor *color;

-(BOOL)isEmpty:(id)thing;

@end


@implementation IFTextPlaceholder

@synthesize text, color;

- (id)initWithText:(NSString*)str color:(UIColor *)col{

	if (self = [super init]) {
		
		self.text = str;
		self.color = col;
	}
	
	return self;
}

- (UIView*)getPlaceholderGraphic:(UIView *)graphic {
	
	CGRect frame = CGRectZero;
	
	frame.size = self.frame.size;
	
	if(!graphic) {
		
		UILabel *lbl = [[[UILabel alloc] init] autorelease];
		
		lbl.frame = frame;
		
		lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth
		| UIViewAutoresizingFlexibleHeight;
		
		if (![self isEmpty:self.text]) {
			lbl.text = self.text;
		}
				
		lbl.opaque = NO;
		lbl.textColor = color;
		lbl.textAlignment = UITextAlignmentCenter;
		lbl.backgroundColor = [UIColor clearColor];
		lbl.font = [UIFont fontWithName:@"Helvetica" size:34];
		lbl.adjustsFontSizeToFitWidth = YES;
		lbl.alpha = 0;
		
		graphic = [[[UIView alloc] initWithFrame:frame] autorelease];
		
		[graphic addSubview:lbl];
	}
	
	if(self.state == IFPlaceholderStateFailed) {
		
		[UIView beginAnimations:nil context:nil];
		
		[[graphic.subviews lastObject] setAlpha:1];
		
		[UIView commitAnimations];
	}
	else
		[[graphic.subviews lastObject] setAlpha:0];
	
	graphic.frame = frame;
	
	return graphic;
}

- (UIView*)getLoadingIndicator:(UIView *)oldLoadingIndicator progress:(NSNumber *)progress {
	
	return nil;
}

-(BOOL)isEmpty:(id)thing {
	return thing == nil
	|| [thing isKindOfClass:[NSNull class]]
	|| ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

- (void)dealloc {

	self.text = nil;
	self.color = nil;
	
	[super dealloc];
}

@end
