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


#import "IFThrottle.h"
#import "IFSettings.h"


@interface IFThrottle ()

@property (retain) NSMutableArray *imageViews;

@property (nonatomic, assign) BOOL forceCheckSoonQueued;

@end


@implementation IFThrottle

@synthesize imageViews, report, forceCheckSoonQueued;

+ (IFThrottle*)shared {
	
	static IFThrottle *instance = 0;
	
	if(!instance)
		instance = [[IFThrottle alloc] init];
	
	return instance;
}

- (void)check {
	
	self.forceCheckSoonQueued = NO;
    
    NSMutableArray *imageViewsCache = [[NSMutableArray alloc] initWithArray:self.imageViews];
	
	if([imageViewsCache count]) {
		
        // Sorted by load priority.
		[imageViewsCache sortUsingSelector:@selector(reverseCompareTo:)];
		
		NSMutableString *str = nil;
		
		if(self.report)
			str = [NSMutableString string];
		
		long long usage = 0;
		
		IFSettings *settings = [IFSettings shared];
		
		int activeCount = 0;
        int loadingCount = 0;
		
		int i = 0;
		
		for(; i < [imageViewsCache count]; i++) {
			
			IFImageView *imageView = [imageViewsCache objectAtIndex:i];
			
			usage += [imageView imageSize];
			
			[str appendFormat:@"(%p) Rank %d %.3fM [Active]\n", imageView, i+1, ([imageView imageSize] / 1024) / 1024.0f];
			
			if(i)
				if([settings memUsage] && usage > [settings memUsage])
					break;
			
			if([settings maxActiveImages] && i >= [settings maxActiveImages])
				break;
			
			if(activeCount < 0)
				continue;
			
            if(!settings.maxLoadingImages || loadingCount < settings.maxLoadingImages)
                [imageView forceLoadEvent];
            
            if(imageView.state == IFImageViewStateFired)
                loadingCount++;
		}
		
		for(; i < [imageViewsCache count]; i++) {
			
			IFImageView *imageView = [imageViewsCache objectAtIndex:i];
			
			[str appendFormat:@"(%p) Rank %d %.3fM\n", imageView, i+1, ([imageView imageSize] / 1024) / 1024.0f];
			
			[imageView forceClearEvent];
		}
		
		if(str)
			self.report.text = str;
	}
    
    [imageViewsCache release];
	
	if(![IFSettings shared].debugMode)
		[self performSelector:@selector(check) withObject:nil afterDelay:0.1];
}

- (id)init {
	
	if((self = [super init])) {
		
        /// An array that does not retain it's elements.
        self.imageViews = (NSMutableArray*)CFArrayCreateMutable
		(NULL, 0, &(const CFArrayCallBacks){0, NULL /* c function called for various events, whatever */, NULL, NULL, NULL});
        
		// Start the check callback loop.
		[self check];
	}
	
	return self;
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	self.imageViews = nil;
	
	[super dealloc];
}

- (void)forceCheckNow {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[self check];
}

- (void)forceCheckSoon {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[self performSelector:@selector(check) withObject:nil afterDelay:0];
	
	self.forceCheckSoonQueued = YES;
}

- (void)clearForceCheckQueue {
	
	if(self.forceCheckSoonQueued)
		[self forceCheckNow];
}

- (void)IFImageFailed:(IFImageView *)imageView error:(NSError *)error {
	
	
}

- (void)IFImageLoaded:(IFImageView *)imageView image:(UIImage *)image {
	
	
}

- (void)add:(IFImageView*)imageView {
	
	[self remove:imageView];
	
	[self.imageViews insertObject:imageView atIndex:0];
	
	[imageView addDelegate:self];
}

- (void)remove:(IFImageView*)imageView {
	
	[imageView removeDelegate:self];
	
	NSUInteger index;
	
	while((index = [self.imageViews indexOfObject:imageView]) != NSNotFound)
		[self.imageViews removeObjectAtIndex:index];
}

@end
