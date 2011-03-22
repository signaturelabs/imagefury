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
@property (nonatomic, assign) CGRect endingRect;

@property (nonatomic, assign) BOOL didSetStartingRect;

@end


@implementation IFTransitionGrow

@synthesize startingRect, endingRect, didSetStartingRect;

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
	
	if(self.reverse)
		rect = CGRectOffset(rect, 0, -20);
	
	self.startingRect = rect;
}

- (void)setStartingRect:(CGRect)rect {
	
	self.didSetStartingRect = YES;
	
	startingRect = rect;
}

- (void)start {
	
	[super start];
	
	UIView *v = [self getToImageView];
	
	CGRect finalRect = v.frame;
	CGRect startRect = self.startingRect;
	
	finalRect.origin = [IFTransition absoluteOrigin:v];
	
	finalRect = CGRectOffset(finalRect, 0, -20);
	
	if(!self.reverse && self.fromController.interfaceOrientation == UIInterfaceOrientationPortrait)
		startRect = CGRectOffset(startRect, 0, -20);
	
	if(!self.reverse && self.fromController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		
		startRect = CGRectOffset(startRect, -20, 0);
	}
	
	if(!self.reverse && UIInterfaceOrientationIsLandscape(self.fromController.interfaceOrientation)) {
		
		CGFloat tmp = finalRect.size.width;
		
		finalRect.size.width = finalRect.size.height;
		finalRect.size.height = tmp;
		
		finalRect.origin.x = 0;
		finalRect.origin.y = -21;
		finalRect.size.width -= 21;
		finalRect.size.height += 1;
	}
	
	UIView *parentView = self.fromController.view;
	
	if(self.reverse)
		parentView = self.toController.view;
	
	[parentView addSubview:v];
	
	// Hack alert
	if(!self.reverse) {
		
		if(!UIInterfaceOrientationIsLandscape(self.fromController.interfaceOrientation)) {
			
			finalRect = CGRectInset(finalRect, 0, 10);
			finalRect.origin.y += 10;
		}
	}
	
	if(self.reverse) {
		
		CGRect temp = finalRect;
		
		finalRect = startRect;
		startRect = temp;
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
