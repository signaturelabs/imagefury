    //
//  IFTransitionViewController.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFTransition.h"
#import <QuartzCore/QuartzCore.h>


@interface IFTransition ()

@property (nonatomic, readwrite, retain) UIImageView *toImage;

@property (nonatomic, retain) UIViewController *fromController;
@property (nonatomic, retain) UIViewController *toController;

@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, assign) BOOL statusBarHidden;

@end


@implementation IFTransition

@synthesize toImage, customToImage;
@synthesize fromController, toController, reverse;
@synthesize isModal, statusBarHidden;

- (UIViewController*)fromController {
	
	return fromController;
}

- (UIViewController*)toController {
	
	return toController;
}

- (UIImage*)takeScreenshot:(UIViewController*)viewController {
	
	UIView *view = viewController.view;
	
	CGSize size = view.bounds.size;
	
	if(UIInterfaceOrientationIsLandscape(viewController.interfaceOrientation)) {
		
		CGFloat tmp = size.width;
		
		size.width = size.height;
		size.height = tmp;
	}
	
	UIGraphicsBeginImageContext(size);
	
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return ret;
}

- (UIImageView*)toImage {
	
	if(!toImage) {
		
		self.toImage = [[UIImageView alloc] init];
		[toImage release];
	}
	
	return toImage;
}

- (id)initWithModalTransitionFrom:(UIViewController*)controller to:(UIViewController*)destination {
	
	if(self = [super init]) {
		
		self.fromController = controller;
		self.toController = destination;
		
		self.isModal = YES;
	}
	
	return self;
}

- (id)initWithNavigationTransitionFrom:(UIViewController*)controller to:(UIViewController*)destination {
	
	if(self = [super init]) {
		
		self.fromController = controller;
		self.toController = destination;
		
		self.isModal = NO;
	}
	
	return self;
}

- (void)dealloc {
	
	self.customToImage = nil;
	self.toImage = nil;
	
	self.fromController = nil;
	self.toController = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	return toInterfaceOrientation == self.fromController.interfaceOrientation;
}

- (void)start {
	
	self.fromController.view;
	self.toController.view;
	
	BOOL statusBarHiddenTemp = [[UIApplication sharedApplication] isStatusBarHidden];
	
	if(self.reverse) {
		
		if(!self.customToImage)
			self.toImage.image = [self takeScreenshot:self.fromController];
		
		if(self.isModal)
			[self.toController dismissModalViewControllerAnimated:NO];
		else
			[self.toController.navigationController popViewControllerAnimated:NO];
	}
	else if(!self.customToImage) {
		
		if(self.isModal)
			[self.fromController
			 presentModalViewController:self.toController
			 animated:NO];
		else
			[self.fromController.navigationController
			 pushViewController:self.toController
			 animated:NO];
		
		self.toImage.image = [self takeScreenshot:self.toController];
		
		if(self.isModal)
			[self.fromController dismissModalViewControllerAnimated:NO];
		else
			[self.fromController.navigationController popViewControllerAnimated:NO];
	}
	
	CGRect toImageFrame = self.toController.view.frame;
	
	self.toImage.frame = toImageFrame;
	
	[[UIApplication sharedApplication] setStatusBarHidden:statusBarHiddenTemp];
}

- (void)finish {
	
	UIViewController *from = self.fromController;
	UIViewController *to = self.toController;
	
	// Undo the reversal for 'finish'
	if(self.reverse) {
		
		return;
	}
	
	if(self.isModal)
		[from
		 presentModalViewController:to
		 animated:NO];
	else
		[from.navigationController
		 pushViewController:to
		 animated:NO];
}

- (UIView*)getToImageView {
	
	if(self.customToImage)
		return self.customToImage;
	
	return self.toImage;
}

+ (CGPoint)absoluteOrigin:(UIView*)view startingOrigin:(CGPoint)p {
	
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

+ (CGPoint)absoluteOrigin:(UIView*)view {
	
	return [IFTransition absoluteOrigin:view startingOrigin:CGPointZero];
}

@end
