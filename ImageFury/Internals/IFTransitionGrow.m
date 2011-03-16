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
		
		startingRect = CGRectZero;
		
		CGSize size = self.fromController.view.frame.size;
		
		startingRect.origin = CGPointMake(size.width / 2, size.height / 2);
	}
	
	return startingRect;
}

- (void)setStartingRectFromView:(UIView*)view {
	
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
	
	[self.fromController.view.window addSubview:v];
	
	CGRect finalRect = v.frame;
	CGRect startRect = self.startingRect;
	
	finalRect.origin = [IFTransition absoluteOrigin:v];
	
	// Hack alert:
	finalRect.origin.y -= 21;
	
	v.frame = self.startingRect;
	
	v.contentMode = UIViewContentModeScaleAspectFill;
	v.clipsToBounds = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDidStopSelector:@selector(finish)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:3];
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
