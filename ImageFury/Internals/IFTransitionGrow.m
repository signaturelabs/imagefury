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
	
	return [self absoluteOrigin:view startingOrigin:CGPointZero];
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

static clock_t t = 0;

- (void)start {
	
	t = clock();
	
	[super start];
	
	clock_t val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"[super start] took %.2f seconds", val / 1000.0f);
	
	t = clock();
	
	UIView *v = [self getToImageView];
	
	[self.fromController.view.window addSubview:v];
	
	CGRect finalRect = v.frame;
	
	finalRect.origin = [self absoluteOrigin:v];
	
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
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"start %.2f seconds", val / 1000.0f);
	
	t = clock();
}

- (void)finish {
	
	clock_t val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"finish called after %.2f seconds", val / 1000.0f);
	
	UIView *v = [self getToImageView];
	
	[v removeFromSuperview];
	
	[super finish];
}

@end
