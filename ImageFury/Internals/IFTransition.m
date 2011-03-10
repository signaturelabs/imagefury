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

@property (nonatomic, readwrite, retain) UIImageView *fromImage;
@property (nonatomic, readwrite, retain) UIImageView *toImage;

@property (nonatomic, retain) UIViewController *fromController;
@property (nonatomic, retain) UIViewController *toController;

@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, retain) UIViewController *oldRootViewController;

@end


@implementation IFTransition

@synthesize fromImage, toImage;
@synthesize fromController, toController;
@synthesize isModal, statusBarHidden;
@synthesize oldRootViewController;

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

- (UIImageView*)fromImage {
	
	if(!fromImage) {
		
		self.fromImage = [[UIImageView alloc] init];
		[fromImage release];
	}
	
	return fromImage;
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
	
	self.fromImage = nil;
	self.toImage = nil;
	
	self.fromController = nil;
	self.toController = nil;
	
	self.oldRootViewController = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	return toInterfaceOrientation == self.fromController.interfaceOrientation;
}

- (void)start {
	
	UIWindow *window = self.fromController.view.window;
	
	self.fromImage.image = [self takeScreenshot:self.fromController];
	
	CGRect fromImageFrame = self.fromController.view.frame;
	
	fromImageFrame.origin = CGPointZero;
	
	self.fromImage.frame = fromImageFrame;
	
	BOOL statusBarHiddenTemp = [[UIApplication sharedApplication] isStatusBarHidden];
	
	if(self.isModal)
		[self.fromController
		 presentModalViewController:self.toController
		 animated:NO];
	else
		[self.fromController.navigationController
		 pushViewController:self.toController
		 animated:NO];
	
	self.toImage.image = [self takeScreenshot:self.toController];
	
	CGRect toImageFrame = self.toController.view.frame;
	
	toImageFrame.origin = CGPointZero;
	
	self.toImage.frame = toImageFrame;
	
	self.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
	
	[[UIApplication sharedApplication] setStatusBarHidden:statusBarHiddenTemp];
	
	self.oldRootViewController = window.rootViewController;
	
	window.rootViewController = self;
}

- (void)finish {
	
	self.view.window.rootViewController = self.oldRootViewController;
	
	[[UIApplication sharedApplication]
	 setStatusBarHidden:self.statusBarHidden
	 withAnimation:UIStatusBarAnimationFade];
}

@end

