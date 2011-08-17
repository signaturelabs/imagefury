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
 Traun Leyden <tleyden@signature-app.com>
 
 */

#import "IFImageView.h"
#import "IFPlaceholder.h"
#import "IFThrottle.h"
#import "IFSettings.h"
#import <QuartzCore/QuartzCore.h>

@interface IFImageView ()

@property (nonatomic, retain) NSMutableArray *delegates;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) IFLoader *loader;

@property (nonatomic, assign) time_t addedToSuperview;

@property (nonatomic, assign) enum IFImageViewState state;

@property (nonatomic, assign) long long sizeEstimate;

@property (nonatomic, assign) BOOL movingToWindow;

- (void)doResizeAfterLoad:(UIImage *)image;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)checkScrollEnabled;

@end

@implementation IFImageView

@synthesize placeholder, requestTimeout, contentMode, panAndZoom, urlRequest;
@synthesize delegates, imageView, loader, state, important, addedToSuperview;
@synthesize sizeEstimate, movingToWindow, resizeAfterLoad;

+ (NSMutableArray*)instances {
	
	static NSMutableArray *instances = 0;
	
	if(!instances)
		// Create a NSMuteableArray that does not retain its objects
		instances = (NSMutableArray*)CFArrayCreateMutable
		(NULL, 0, &(const CFArrayCallBacks){0, NULL, NULL, NULL, NULL});
	
	return instances;
}

- (void)setup {
	
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.bouncesZoom = YES;
	self.decelerationRate = UIScrollViewDecelerationRateFast;
	self.delegate = self; 
	
	[self setMaxMinZoomScalesForCurrentBounds];
}

- (void)setPanAndZoom:(BOOL)yesOrNo {
	
	panAndZoom = yesOrNo;
	
	[self checkScrollEnabled];
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.frame.size;
    CGSize imageSize = imageView.image.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MAX(1, MIN(xScale, yScale));                 // use minimum of these to allow the image to become fully visible
    
    xScale = imageSize.width / boundsSize.width;
    yScale = imageSize.height / boundsSize.height;
    CGFloat maxScale = MAX(1, MAX(xScale, yScale));
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (void)checkScrollEnabled {
	
	[self setup];
	
	if(self.panAndZoom) {
		
		self.scrollEnabled = YES;
	}
	else {
		
		self.scrollEnabled = NO;
		self.maximumZoomScale = self.minimumZoomScale = 1;
	}
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	
	[self checkScrollEnabled];
	
	if(newWindow) {
		
		self.movingToWindow = YES;
		
		[[IFThrottle shared] forceCheckSoon];
	}
}

- (void)didMoveToWindow {
	
	[[IFThrottle shared] clearForceCheckQueue];
	
	self.movingToWindow = NO;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	if([[IFImageView instances] indexOfObject:self] == NSNotFound)
		[[IFImageView instances] addObject:self];
	
	// Ensure placeholder is loaded.
	(void)self.placeholder;
	
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
	self.placeholder.contentMode = contentMode;
}

- (NSMutableArray*)delegates {
	
	if(!delegates) {
		
		// Create a NSMuteableArray that does not retain its objects
		self.delegates = (NSMutableArray*)CFArrayCreateMutable
		(NULL, 0, &(const CFArrayCallBacks){0, NULL, NULL, NULL, NULL});
	}
	
	return delegates;
}

- (IFPlaceholder*)placeholder {
	
	if(!placeholder) {
		
		Class class = [[IFSettings shared] defaultPlaceholderClass];
		
		self.placeholder = [[class alloc] init];
		[placeholder release];
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		placeholder.frame = frame;
		
		placeholder.state = placeholder.state;
	}
	
	[self insertSubview:placeholder atIndex:0];
	[self bringSubviewToFront:placeholder];
	
	return placeholder;
}

- (void)setFrame:(CGRect)rect {
		
	[super setFrame:rect];
	
	CGRect frame = CGRectZero;
	
	frame.size = self.frame.size;
	
	if(placeholder) {
		
		self.placeholder.frame = frame;
	}
	
	if(imageView) {
		
		self.imageView.frame = frame;
	}
}

- (UIImageView*)imageView {
	
	if(!imageView) {
		
		CGRect frame = CGRectZero;
		
		frame.size = self.frame.size;
		
		self.imageView = [[UIImageView alloc] initWithFrame:frame];
		[imageView release];
		
		imageView.backgroundColor = [UIColor clearColor];
	}
	
	[self addSubview:imageView];
	
	return imageView;
}

- (void)setImageView:(UIImageView *)newImageView {
	
	[newImageView retain];
	[imageView release];
	imageView = newImageView;
	
	imageView.contentMode = self.contentMode;
}

- (void)setPlaceholder:(IFPlaceholder *)newPlaceholder {
	
	[newPlaceholder retain];
	
	[placeholder removeFromSuperview];
	[placeholder release];
	placeholder = newPlaceholder;
	
	placeholder.state = placeholder.state;
	
	placeholder.contentMode = self.contentMode;
	
	self.frame = self.frame;
	
	[self insertSubview:placeholder atIndex:0];
	[self bringSubviewToFront:placeholder];
}

- (void)addDelegate:(id <IFImageViewDelegate>)delegate {
	
	[self.delegates addObject:delegate];
}

- (void)removeDelegate:(id <IFImageViewDelegate>)delegate {
	
	[self.delegates removeObject:delegate];
}

- (void)softClearEvent {
	
	self.loader.running = NO;
	
	self.placeholder.state = IFPlaceholderStatePreload;
	
	self.imageView.image = nil;
	
	self.state = IFImageViewStateCleared;
    
    NSArray *delegatesCache = [[NSArray alloc] initWithArray:self.delegates];
	
	for(id<IFImageViewDelegate> delegate in delegatesCache)
		if([delegate respondsToSelector:@selector(IFImageCanceled:)])
			[delegate IFImageCanceled:self];
    
    [delegatesCache release];
}

- (void)forceClearEvent {
	
	[self softClearEvent];
	
	self.imageView.alpha = 0;
}

- (void)setUrlRequest:(NSURLRequest *)request {
    
    if(self.placeholder.state != IFPlaceholderStateFailed && [urlRequest.URL isEqual:request.URL])
        return;
    
    if(urlRequest)
        [self softClearEvent];
	
	[request retain];
	[urlRequest release];
	urlRequest = request;
	
	if(!urlRequest) {
        
        self.loader.delegate = nil;
        self.loader = nil;
        
		return;
    }
	
	self.loader.running = NO;
	self.loader.delegate = nil;
	self.loader = [IFLoader new];
	[self.loader release];
	
	self.loader.delegate = self;
	self.loader.cacheDir = [[IFSettings shared] cacheDirectory];
	self.loader.tempCacheDir = [[IFSettings shared] tempCacheDirectory];
	self.loader.urlRequest = request;
	
	if([self.loader nonEmptyFileExists]) {
		
		self.placeholder.state = IFPlaceholderStatePreload;
	}
	else {
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		self.imageView.alpha = 0;
		
		[UIView commitAnimations];
		
		self.placeholder.state = IFPlaceholderStateLoading;
	}
	
	[[IFThrottle shared] add:self];
}

- (void)setURL:(NSURL *)url {
	
	if(!url) {
		
		[self setUrlRequest:nil];
		return;
	}
	
	self.urlRequest =
	[NSURLRequest
	 requestWithURL:url
	 cachePolicy:NSURLCacheStorageNotAllowed
	 timeoutInterval:self.requestTimeout];
}

- (void)setURLString:(NSString *)url {
	
	if(!url) {
		
		[self setUrlRequest:nil];
		return;
	}
	
	[self setURL:[NSURL URLWithString:url]];
}

- (NSString*)description {
    
    NSString *stateStr = @"Invalid";
    
    if(self.state == IFImageViewStateCleared)
        stateStr = @"Cleared";
    
    if(self.state == IFImageViewStateFired)
        stateStr = @"Fired(Loading)";
    
    if(self.state == IFImageViewStateLoaded)
        stateStr = @"Loaded";
    
    return
    [NSString stringWithFormat:
     @"<IFImageView %p> priority: %d, state: %@, url: %@, placeholder: %@",
     self, self.loadPriority, stateStr, self.urlRequest.URL, self.placeholder];
}

- (void)IFLoaderFailed:(NSError *)error {
	
	self.placeholder.state = IFPlaceholderStateFailed;
	
	NSLog(@"Image Fury Loader Failed: %@", error);
    
    // Delegate may release us
    [[self retain] release];
	
    NSArray *delegatesCache = [[NSArray alloc] initWithArray:self.delegates];
	
	for(id<IFImageViewDelegate> delegate in delegatesCache)
		if([delegate respondsToSelector:@selector(IFImageFailed:error:)])
			[delegate IFImageFailed:self error:error];
    
    [delegatesCache release];
}

- (void)IFLoaderProgress:(CGFloat)progress updateCount:(int)updateCount {
	
	self.placeholder.state = IFPlaceholderStateLoading;
	
	if(updateCount > 1)
		[self.placeholder setProgress:progress];
}

- (void)IFLoaderComplete:(NSString *)filename {
	
	self.state = IFImageViewStateLoaded;
	
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
	
	self.imageView.image = image;
	
	[image release];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
	
	self.imageView.alpha = 1;
	
	[UIView commitAnimations];
	
	self.placeholder.state = IFPlaceholderStateSuccess;
    
    if(self.resizeAfterLoad) 
        [self doResizeAfterLoad:image];
	
	[self checkScrollEnabled];
    
    NSArray *delegatesCache = [[NSArray alloc] initWithArray:self.delegates];
	
	for(id<IFImageViewDelegate> delegate in delegatesCache)
		if([delegate respondsToSelector:@selector(IFImageLoaded:image:)])
			[delegate IFImageLoaded:self image:image];
    
    [delegatesCache release];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    imageView.frame = frameToCenter;
	
	[self checkScrollEnabled];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(!self.dragging) {
		
		[self.nextResponder touchesEnded:touches withEvent:event];
		
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)forceLoadEvent {
	
	if(self.state == IFImageViewStateCleared) {
		
		self.state = IFImageViewStateFired;
		
		if(!self.loader)
			[self setUrlRequest:self.urlRequest];
		
		self.loader.running = YES;
	}
}

- (long long)imageSize {
	
	return self.sizeEstimate;
}

- (UIScrollView*)parentScrollView {
	
	UIView *v = self;
	
	while((v = v.superview))
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
	
	int ret =  1000000;
	
	if(!self.superview)
		ret -= 1000000;
	
	if(self.movingToWindow)
		ret += 100000;
	
	if(!self.window) {
        
        if(self.important)
            ret -=      1;
        else
            ret -= 100000;
    }
	
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

- (void)doResizeAfterLoad:(UIImage *)image {
	
	CGRect frame = self.frame;
	
	CGFloat aspect = self.frame.size.height / image.size.height;
	
	frame.size =
	CGSizeMake(image.size.width * aspect,
			   self.frame.size.height);
	
	if(frame.size.width > self.frame.size.width) {
		
		aspect = self.frame.size.width / image.size.width;
		
		frame.size =
		CGSizeMake(self.frame.size.width,
				   image.size.height * aspect);
		
		frame.origin.y += (self.frame.size.height - frame.size.height) / 2;
	}
	
	self.frame = frame;
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
