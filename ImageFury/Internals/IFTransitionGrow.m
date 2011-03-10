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

- (CGPoint)absoluteOrigin:(UIView*)view startingOrigin:(CGPoint)p {
	
	if(!view || [view isKindOfClass:[UIWindow class]])
		return p;
	
	p.x += view.frame.origin.x;
	p.y += view.frame.origin.y;
	
	UIView *parent = view.superview;
	
	if([parent isKindOfClass:[UIScrollView class]]) {
		
		UIScrollView *scrollView = (UIScrollView*)parent;
		
		p.x -= scrollView.contentOffset.x;
		p.y -= scrollView.contentOffset.y;
	}
	
	p = [self absoluteOrigin:parent startingOrigin:p];
	
	return p;
}

- (CGPoint)absoluteOrigin:(UIView*)view {
	
	// Hack alert: Not sure why I need to -20 here.  The status bar is 20
	// pixels tall --- hmmmm.........
	
	return [self absoluteOrigin:view startingOrigin:CGPointMake(0, -20)];
}

- (void)setStartingRectFromView:(UIView*)view {
	
	CGRect rect = view.frame;
	
	rect.origin = [self absoluteOrigin:view];
	
	self.startingRect = rect;
}

- (void)setStartingRect:(CGRect)rect {
	
	self.didSetStartingRect = YES;
	
	startingRect = rect;
}

- (void)start {
	
	[super start];
	
	[self.view addSubview:self.fromImage];
	[self.view addSubview:self.toImage];
	
	CGRect finalRect = self.toImage.frame;
	
	self.toImage.frame = self.startingRect;
	
	self.toImage.contentMode = UIViewContentModeScaleAspectFill;
	self.toImage.clipsToBounds = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDidStopSelector:@selector(finish)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.45];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	self.toImage.frame = finalRect;
	
	[UIView commitAnimations];
}

- (void)finish {
	
	[super finish];
}

@end
