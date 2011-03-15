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
@synthesize fromController, toController;
@synthesize isModal, statusBarHidden;

- (UIImage*)takeScreenshot:(UIViewController*)viewController {
	
	clock_t t, val;
	
	t = clock();
	
	UIView *view = viewController.view;
	
	CGSize size = view.bounds.size;
	
	if(UIInterfaceOrientationIsLandscape(viewController.interfaceOrientation)) {
		
		CGFloat tmp = size.width;
		
		size.width = size.height;
		size.height = tmp;
	}
	
	UIGraphicsBeginImageContext(size);
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"the rest took %.2f seconds", val / 1000.0f);
	
	t = clock();
	
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"renderInContext took %.2f seconds", val / 1000.0f);
	
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
	
	self.toImage = nil;
	
	self.fromController = nil;
	self.toController = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	return toInterfaceOrientation == self.fromController.interfaceOrientation;
}

- (void)start {
	
	clock_t t, val;
	
	self.fromController.view;
	self.toController.view;
	
	t = clock();
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"loading view controller views took %.2f seconds", val / 1000.0f);
	
	BOOL statusBarHiddenTemp = [[UIApplication sharedApplication] isStatusBarHidden];
	
	t = clock();
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"pushViewController took %.2f seconds", val / 1000.0f);
	
	t = clock();
	
	if(!self.customToImage) {
		
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
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"stuff after screenshot took %.2f seconds", val / 1000.0f);
	
	t = clock();
	
	val = (clock() - t) / (CLOCKS_PER_SEC / 1000);
	
	NSLog(@"stuff after after screenshot took %.2f seconds", val / 1000.0f);
}

- (void)finish {
	
	if(self.isModal)
		[self.fromController
		 presentModalViewController:self.toController
		 animated:NO];
	else
		[self.fromController.navigationController
		 pushViewController:self.toController
		 animated:NO];
}

- (UIView*)getToImageView {
	
	if(self.customToImage)
		return self.customToImage;
	
	return self.toImage;
}

@end
