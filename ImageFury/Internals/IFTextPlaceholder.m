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
@property (nonatomic) CGFloat textSize;
@property (nonatomic, retain) NSString *fontName;

-(BOOL)isEmpty:(id)thing;

@end


@implementation IFTextPlaceholder

@synthesize text, color, textSize, fontName;

- (id)initWithText:(NSString*)_text color:(UIColor *)_color {
    return [self initWithText:_text color:_color size:nil font:@"Helvetica"];
}

- (id)initWithText:(NSString*)str color:(UIColor *)col size:(NSNumber *)sz font:(NSString *)font{

	if ((self = [super init])) {
		
		self.text = str;
		self.color = col;
		
        if(sz != nil)
            self.textSize = [sz floatValue];
        else
            self.textSize = 34.0;
        
        if(font != nil){
            self.fontName = font;
        }else{
            self.fontName = @"Helvetica";
        }
	}
	
	return self;
}

- (UIView*)getPlaceholderGraphic:(UIView *)graphic {
	
	CGRect frame = CGRectZero;
	
	frame.size = self.frame.size;
	
	if(!graphic) {
		
        UILabel *textLabel = [[UILabel alloc] init];
		
		textLabel.frame = frame;
		
		textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
		| UIViewAutoresizingFlexibleHeight;
		
		if (![self isEmpty:self.text])
			textLabel.text = self.text;
		
		textLabel.opaque = NO;
		
		if(color)
			textLabel.textColor = color;
		
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.font = [UIFont fontWithName:self.fontName size:self.textSize];
		textLabel.adjustsFontSizeToFitWidth = YES;
		textLabel.alpha = 0;
		
		graphic = [[[UIView alloc] initWithFrame:frame] autorelease];
		
		[graphic addSubview:textLabel];
		[textLabel release];
	}
	
	if(self.state == IFPlaceholderStateFailed || self.state == IFPlaceholderStatePreload) {
		
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

- (BOOL)isEmpty:(id)thing {
	
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
	self.fontName = nil;
	
	[super dealloc];
}

@end
