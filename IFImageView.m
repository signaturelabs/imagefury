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

#import "IFImageView.h"
#import "IFPlaceholder.h"
#import "IFThrottle.h"
#import "IFSettings.h"
#import <QuartzCore/QuartzCore.h>


enum IFImageViewState {
	IFImageViewStateCleared = 0,
	IFImageViewStateFired
};

@interface IFImageView ()

@property (nonatomic, retain) NSMutableArray *delegates;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) IFLoader *loader;

@property (nonatomic, assign) time_t addedToSuperview;

@property (nonatomic, assign) enum IFImageViewState state;

@property (nonatomic, assign) long long sizeEstimate;

@end

@implementation IFImageView

@synthesize placeholder, requestTimeout, contentMode, urlRequest;
@synthesize delegates, imageView, loader, state, addedToSuperview;
@synthesize sizeEstimate;

+ (NSMutableArray*)instances {
	
	static NSMutableArray *instances = 0;
	
	if(!instances)
		instances =
		(NSMutableArray*)
		CFArrayCreateMutable(NULL, 0,
							 &(const CFArrayCallBacks){0, NULL, NULL, NULL, NULL});
	
	return instances;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if([[IFImageView instances] indexOfObject:self] == NSNotFound)
		[[IFImageView instances] addObject:self];
	
	// Ensure placeholder is loaded.
	self.placeholder;
	
	self.addedToSuperview = time(0);
}

- (int)requestTimeout {
	
	if(!requestTimeout)
		self.requestTimeout = [[IFSettings shared] defaultTimeout];
	
	return requestTimeout;
}

- (UIViewContentMode)contentMode {
	
	if(!contentMode)
		self.contentMode = UIViewContentModeScaleAspectFit;
	
	return contentMode;
}

- (void)setContentMode:(UIViewContentMode)mode {
	
	contentMode = mode;
	
	self.imageView.contentMode = contentMode;
}

- (NSMutableArray*)delegates {
	
	if(!delegates) {
		
		self.delegates =
		(NSMutableArray*)
		CFArrayCreateMutable(NULL, 0,
							 &(const CFArrayCallBacks){0, NULL, NULL, NULL, NULL});
	}
	
	return delegates;
}

- (IFPlaceholder*)placeholder {
	
	if(!placeholder) {
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		Class class = [[IFSettings shared] defaultPlaceholderClass];
		
		self.placeholder = [[class alloc] initWithFrame:frame];
		[placeholder release];
	}
	
	return placeholder;
}

- (void)setFrame:(CGRect)rect {
		
	[super setFrame:rect];
	
	CGRect frame = CGRectZero;
	
	frame.size = self.frame.size;
	
	if(placeholder)
		self.placeholder.frame = frame;
	
	if(imageView)
		self.imageView.frame = frame;
}

- (UIImageView*)imageView {
	
	if(!imageView) {
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		self.imageView = [[UIImageView alloc] initWithFrame:frame];
		[imageView release];
		
		[self insertSubview:imageView aboveSubview:self.placeholder];
	}
	
	return imageView;
}

- (void)setImageView:(UIImageView *)newImageView {
	
	[newImageView retain];
	[imageView release];
	imageView = newImageView;
	
	imageView.contentMode = self.contentMode;
}

- (void)setPlaceholder:(IFPlaceholder *)newPlaceholder {
	
	[placeholder removeFromSuperview];
	
	[newPlaceholder retain];
	[placeholder release];
	placeholder = newPlaceholder;
	
	[self insertSubview:placeholder atIndex:0];
}

- (void)addDelegate:(id <IFImageViewDelegate>)delegate {
	
	[self.delegates addObject:delegate];
}

- (void)removeDelegate:(id <IFImageViewDelegate>)delegate {
	
	[self.delegates removeObject:delegate];
}

- (void)setUrlRequest:(NSURLRequest *)request {
	
	[request retain];
	[urlRequest release];
	urlRequest = request;
	
	if(!urlRequest)
		return;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	self.imageView.alpha = 0;
	
	[UIView commitAnimations];
	
	[self forceClearEvent];
	
	self.loader = [[IFLoader alloc] init];
	[self.loader release];
	
	self.loader.delegate = self;
	self.loader.cacheDir = [[IFSettings shared] cacheDirectory];
	self.loader.tempCacheDir = [[IFSettings shared] tempCacheDirectory];
	self.loader.urlRequest = request;
	
	self.placeholder.state = IFPlaceholderStateLoading;
	
	[[IFThrottle shared] add:self];
}

- (void)setURL:(NSURL *)url {
	
	self.urlRequest =
	[NSURLRequest
	 requestWithURL:url
	 cachePolicy:NSURLCacheStorageNotAllowed
	 timeoutInterval:self.requestTimeout];
}

- (void)setURLString:(NSString *)url {
	
	[self setURL:[NSURL URLWithString:url]];
}

- (void)IFLoaderFailed:(NSError *)error {
	
	self.placeholder.state = IFPlaceholderStateFailed;
	
	NSLog(@"Image Fury Loader Failed: %@", error);
	
	for(id<IFImageViewDelegate> delegate in self.delegates)
		if([delegate respondsToSelector:@selector(IFImageFailed:error:)])
			[delegate IFImageFailed:self error:error];
}

- (void)IFLoaderProgress:(CGFloat)progress updateCount:(int)updateCount {
	
	self.placeholder.state = IFPlaceholderStateLoading;
	
	if(updateCount > 1)
		[self.placeholder setProgress:progress];
}

- (void)IFLoaderComplete:(NSString *)filename {
	
	NSLog(@"IFLoaderComplete:%@", filename);
	
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:filename];
	
	CGSize s = image.size;
	
	self.sizeEstimate = s.width * s.height * 4;
	
	if(image == nil) {
		
		NSString *msg =
		[NSString
		 stringWithFormat:
		 @"Image Fury Failed to find valid data for url: %@.\nInvalid data saved to this file: %@",
		 self.urlRequest.URL, filename];
		
		NSLog(@"%@", msg);
		
		[self IFLoaderFailed:
		 [NSError
		  errorWithDomain:msg
		  code:0
		  userInfo:nil]];
		
		return;
	}
	
	self.imageView.alpha = 0;
	self.imageView.image = image;
	
	[image release];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	self.imageView.alpha = 1;
	
	[UIView commitAnimations];
	
	self.placeholder.state = IFPlaceholderStateSuccess;
	
	for(id<IFImageViewDelegate> delegate in self.delegates)
		if([delegate respondsToSelector:@selector(IFImageLoaded:image:)])
			[delegate IFImageLoaded:self image:image];
}

- (void)forceLoadEvent {
	
	if(self.state == IFImageViewStateCleared) {
		
		self.loader.running = YES;
		
		self.state = IFImageViewStateFired;
	}
}

- (void)forceClearEvent {
	
	self.loader.running = NO;
	
	self.placeholder.state = IFPlaceholderStatePreload;
	
	self.imageView.image = nil;
	
	self.state = IFImageViewStateCleared;
}

- (long long)imageSize {
	
	return self.sizeEstimate;
}

- (UIScrollView*)parentScrollView {
	
	UIView *v = self;
	
	while(v = v.superview)
		if([v isKindOfClass:[UIScrollView class]])
			return (UIScrollView*)v;
	
	return nil;
}

- (CGRect)getActiveArea {
	
	CGRect ret = self.superview.frame;
	
	UIScrollView *scroll = [self parentScrollView];
	
	if(scroll)
		ret.origin = scroll.contentOffset;
	
	return ret;
}

- (CGPoint)getCenter:(CGRect)rect {
	
	return
	CGPointMake(rect.origin.x + rect.size.width / 2,
				rect.origin.y + rect.size.height / 2);
}

- (double)getDistance:(CGPoint)point point:(CGPoint)point2 {
	
	return hypot(point.x - point2.x, point.y - point2.y);
}

- (int)loadPriority {
	
	int ret = 1000000;
	
	if(!self.superview)
		ret -= 1000000;
	
	if(!self.window)
		ret -= 100000;
	
	if(self.hidden)
		ret -= 10000;
	
	if(self.alpha < 0.05)
		ret -= 10000;
	
	if(CGRectIntersectsRect([self getActiveArea], self.frame)) {
		
		ret += 1000;
		
		if(self.superview)
			ret -= MIN(0, MAX(1000, (time(0) - self.addedToSuperview)));
	}
	else {
		
		ret -= (int)
		[self
		 getDistance:
		 [self getCenter:
		  [self getActiveArea]]
		 point:self.center];
	}
	
	return ret;
}

- (NSComparisonResult)compareTo:(IFImageView*)iv {
	
	int me = [self loadPriority];
	int them = [iv loadPriority];
	
	if(me < them)
		return NSOrderedAscending;
	
	if(me > them)
		return NSOrderedDescending;
	
	return NSOrderedSame;
}

- (NSComparisonResult)reverseCompareTo:(IFImageView*)iv {
	
	int me = [self loadPriority];
	int them = [iv loadPriority];
	
	if(me < them)
		return NSOrderedDescending;
	
	if(me > them)
		return NSOrderedAscending;
	
	return NSOrderedSame;
}

+ (void)clearCache {
	
	[[NSFileManager defaultManager]
	 removeItemAtPath:[[IFSettings shared] cacheDirectory] error:nil];
	
	IFSettings *settings = [IFSettings shared];
	
	settings.cacheDirectory = settings.cacheDirectory;
}

- (void)dealloc {
	
	[[IFImageView instances] removeObject:self];
	
	[[IFThrottle shared] remove:self];
	
	[self.imageView.layer removeAllAnimations];
	
	self.loader.running = NO;
	
	self.placeholder = nil;
	self.urlRequest = nil;
	
	self.delegates = nil;
	
	self.imageView.image = nil;
	self.imageView = nil;
	
	self.loader.delegate = nil;
	self.loader = nil;
	
	[super dealloc];
}

@end
