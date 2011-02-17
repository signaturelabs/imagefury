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


#import "IFPlaceholder.h"
#import <QuartzCore/QuartzCore.h>


@interface IFPlaceholder ()

@property (nonatomic, retain) UIView *placeholderGraphic;
@property (nonatomic, retain) UIView *loadingIndicator;
@property (nonatomic, assign) BOOL showProgress;

@end

@implementation IFPlaceholder

@synthesize state, placeholderGraphic, loadingIndicator, showProgress;

- (void)setFrame:(CGRect)rect {
	
	[super setFrame:rect];
	
	[self.placeholderGraphic removeFromSuperview];
	self.placeholderGraphic = nil;
	
	[self.loadingIndicator removeFromSuperview];
	self.loadingIndicator = nil;
	
	self.state = self.state;
}

- (void)setState:(IFPlaceholderState)newState {
	
	IFPlaceholderState oldState = state;
	
	state = newState;
	
	if(oldState == newState)
		return;
	
	if(self.placeholderGraphic && self.placeholderGraphic.layer)
		[self.placeholderGraphic.layer removeAllAnimations];
	
	if(self.loadingIndicator && self.loadingIndicator.layer)
		[self.loadingIndicator.layer removeAllAnimations];
	
	[self.placeholderGraphic removeFromSuperview];
	[self.loadingIndicator removeFromSuperview];
	
	self.placeholderGraphic = [self getPlaceholderGraphic:self.placeholderGraphic];
	self.loadingIndicator = [self getLoadingIndicator:self.loadingIndicator progress:nil];
	
	[self addSubview:self.placeholderGraphic];
	[self addSubview:self.loadingIndicator];
	
	if(newState == IFPlaceholderStatePreload && oldState == IFPlaceholderStatePreload)
		self.loadingIndicator.alpha = 0;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	if(state == IFPlaceholderStatePreload) {
		
		self.placeholderGraphic.alpha = 1;
		self.loadingIndicator.alpha = 0;
	}
	else if(state == IFPlaceholderStateLoading) {
		
		self.placeholderGraphic.alpha = 1;
		self.loadingIndicator.alpha = 1;
	}
	else if(state == IFPlaceholderStateFailed) {
		
		self.placeholderGraphic.alpha = 1;
		self.loadingIndicator.alpha = 0;
	}
	else if(state == IFPlaceholderStateSuccess) {
		
		self.placeholderGraphic.alpha = 0;
		self.loadingIndicator.alpha = 0;
	}
	
	[UIView commitAnimations];
}

- (void)setProgress:(CGFloat)progress {
	
	[self
	 getLoadingIndicator:self.loadingIndicator
	 progress:[NSNumber numberWithFloat:progress]];
}

- (UIView*)getPlaceholderGraphic:(UIView *)graphic {
	
	if(!graphic) {
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		graphic = [[[UIView alloc] init] autorelease];
		
		graphic.frame = frame;
		
		graphic.backgroundColor = [UIColor grayColor];
	}
	
	return graphic;
}

- (UIView*)getLoadingIndicator:(UIView *)indicatorView progress:(NSNumber*)progress {
	
	const int activityViewTag = 1336;
	const int progressViewTag = 1337;
	
	if(!indicatorView) {
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		indicatorView = [[[UIView alloc] init] autorelease];
		
		indicatorView.frame = frame;
		
		indicatorView.backgroundColor =
		[[UIColor blackColor]
		 colorWithAlphaComponent:0.5];
		
		UIView *activityView = [[[UIView alloc] init] autorelease];
		
		activityView.frame = frame;
		
		[indicatorView addSubview:activityView];
		
		activityView.tag = activityViewTag;
		
		UIActivityIndicatorView *activity =
		[[[UIActivityIndicatorView alloc]
		  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]
		 autorelease];
		
		activity.center = indicatorView.center;
		
		[activity startAnimating];
		
		[activityView addSubview:activity];
		
		UIProgressView *progressView =
		[[[UIProgressView alloc]
		 initWithProgressViewStyle:UIProgressViewStyleDefault]
		 autorelease];
		
		progressView.tag = progressViewTag;
		
		CGPoint p = indicatorView.center;
		
		p.y += 10;
		
		progressView.center = p;
		progressView.alpha = 0;
		
		[indicatorView addSubview:progressView];
	}
	
	UIView *activity = (id)[indicatorView viewWithTag:activityViewTag];
	UIProgressView *progressView = (id)[indicatorView viewWithTag:progressViewTag];
	
	if(progress && progressView.frame.size.width <= self.frame.size.width) {
		
		progressView.progress = [progress floatValue];
		
		// Transition into progress bar mode.
		
		if(self.showProgress)
			; // But don't repeat the transition
		else {
			
			self.showProgress = YES;
			
			if(activity && activity.layer)
				[activity.layer removeAllAnimations];
			
			if(progressView && progressView.layer)
				[progressView.layer removeAllAnimations];
			
			activity.center = indicatorView.center;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.25];
			
			CGPoint p;
			
			p.x = self.frame.size.width / 2;
			p.y = self.frame.size.height/ 2;
			
			p.y -= 10;
			
			activity.center = p;
			
			progressView.alpha = 1;
			
			[UIView commitAnimations];
		}
	}
	else {
		
		// Transition out of progress bar mode.
		
		if(!self.showProgress)
			; // But don't repeat the transition
		else {
			
			self.showProgress = NO;
			
			if(activity && activity.layer)
				[activity.layer removeAllAnimations];
			
			if(progressView && progressView.layer)
				[progressView.layer removeAllAnimations];
			
			CGPoint p;
			
			p.x = self.frame.size.width / 2;
			p.y = self.frame.size.height/ 2;
			
			p.y -= 10;
			
			activity.center = p;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.25];
			
			p.x = self.frame.size.width / 2;
			p.y = self.frame.size.height/ 2;
			
			activity.center = p;
			
			progressView.alpha = 0;
			
			[UIView commitAnimations];
		}
	}
	
	return indicatorView;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	if(!self.state)
		self.state = IFPlaceholderStatePreload;
}

- (void)dealloc {
	
	if(self.placeholderGraphic && self.placeholderGraphic.layer)
		[self.placeholderGraphic.layer removeAllAnimations];
	
	if(self.loadingIndicator && self.loadingIndicator.layer)
		[self.loadingIndicator.layer removeAllAnimations];
	
	self.placeholderGraphic = nil;
	self.loadingIndicator = nil;
	
	[super dealloc];
}

@end
