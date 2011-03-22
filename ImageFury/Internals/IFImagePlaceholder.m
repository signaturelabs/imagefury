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
 
 */

#import "IFImagePlaceholder.h"


@interface IFImagePlaceholder ()

@property (nonatomic, assign) UIImageView *imageView;

@end


@implementation IFImagePlaceholder

@synthesize imageView;

- (id)initWithImage:(UIImage*)image {
	
	if(self = [super init]) {
		
		self.imageView =
		[[UIImageView alloc] initWithImage:image];
		
		imageView.backgroundColor = [UIColor grayColor];
		
		imageView.contentMode = self.contentMode;
		
		[self addSubview:imageView];
		[imageView release];
	}
	
	return self;
}

- (void)nilImage {
	
	self.imageView.image = nil;
	[self.imageView removeFromSuperview];
	self.imageView = nil;
}

- (void)dealloc {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[self nilImage];
	
	[super dealloc];
}

- (void)setState:(IFPlaceholderState)newState {
	
	[super setState:newState];
	
	if(newState == IFPlaceholderStateSuccess) {
		
		[self performSelector:@selector(nilImage) withObject:nil afterDelay:1];
	}
}

- (void)setContentMode:(UIViewContentMode)mode {
	
	[super setContentMode:mode];
	
	self.imageView.contentMode = mode;
}

- (void)setFrame:(CGRect)rect {
	
	[super setFrame:rect];
	
	rect.origin = CGPointZero;
	
	self.imageView.frame = rect;
}

- (UIView*)getPlaceholderGraphic:(UIView*)oldPlaceholderGraphic {
	
	return nil;
}

- (UIView*)getLoadingIndicator:(UIView*)oldLoadingIndicator progress:(NSNumber*)progress {
	
	return nil;
}

@end
