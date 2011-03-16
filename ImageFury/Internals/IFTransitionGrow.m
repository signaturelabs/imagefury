    //
//  IFTransitionGrow.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFTransitionGrow.h"
#import <QuartzCore/QuartzCore.h>


@interface IFTransitionGrow ()

@property (nonatomic, assign) CGRect startingRect;

@property (nonatomic, assign) BOOL didSetStartingRect;

@end


@implementation IFTransitionGrow

@synthesize startingRect, didSetStartingRect;

- (CGRect)startingRect {
	
	if(!self.didSetStartingRect) {
		
		CGRect r = CGRectZero;
		
		CGSize size = self.fromController.view.frame.size;
		
		if(self.reverse)
			size = self.toController.view.frame.size;
		
		r.origin = CGPointMake(size.width / 2, size.height / 2);
		
		self.startingRect = r;
	}
	
	return startingRect;
}

- (void)setStartingRectFromView:(UIView*)view {
	
	if(!view)
		return;
	
	CGRect rect = view.frame;
	
	rect.origin = [IFTransition absoluteOrigin:view];
	
	self.startingRect = rect;
}

- (void)setStartingRect:(CGRect)rect {
	
	self.didSetStartingRect = YES;
	
	startingRect = rect;
}

- (void)start {
	
	[super start];
	
	UIView *v = [self getToImageView];
	
	UIWindow *window = self.fromController.view.window;
	
	if(self.reverse)
		window = self.toController.view.window;
	
	[window addSubview:v];
	
	CGRect finalRect = v.frame;
	CGRect startRect = self.startingRect;
	
	finalRect.origin = [IFTransition absoluteOrigin:v];
	
	// Hack alert
	if(!self.reverse) {
		
		finalRect = CGRectInset(finalRect, 0, 10);
		finalRect.origin.y -= 11;
	}
	
	if(self.reverse) {
		
		finalRect = self.startingRect;
		startRect = v.frame;
	}
	
	v.frame = startRect;
	
	v.contentMode = UIViewContentModeScaleAspectFill;
	v.clipsToBounds = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDidStopSelector:@selector(finish)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.45];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	v.frame = finalRect;
	
	[UIView commitAnimations];
}

- (void)finish {
	
	UIView *v = [self getToImageView];
	
	[v removeFromSuperview];
	
	[super finish];
}

@end
