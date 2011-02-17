//
//  IFThrottle.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFThrottle.h"
#import "IFSettings.h"


@interface IFThrottle ()

@property (nonatomic, retain) NSMutableArray *imageViews;

@end


@implementation IFThrottle

@synthesize imageViews, report;

+ (IFThrottle*)shared {
	
	static IFThrottle *instance = 0;
	
	if(!instance)
		instance = [[IFThrottle alloc] init];
	
	return instance;
}

- (void)check {
	
	if([self.imageViews count]) {
		
		[self.imageViews sortUsingSelector:@selector(reverseCompareTo:)];
		
		NSMutableString *str = nil;
		
		if(self.report)
			str = [NSMutableString string];
		
		long long usage = 0;
		
		IFSettings *settings = [IFSettings shared];
		
		int i = 0;
		
		for(; i < [self.imageViews count]; i++) {
			
			IFImageView *imageView = [self.imageViews objectAtIndex:i];
			
			usage += [imageView imageSize];
			
			[str appendFormat:@"(%p) Rank %d %.3fM [Active]\n", imageView, i+1, ([imageView imageSize] / 1024) / 1024.0f];
			
			if(i)
				if([settings memUsage] && usage > [settings memUsage])
					break;
			
			if([settings maxActiveImages] && i >= [settings maxActiveImages])
				break;
			
			[imageView forceLoadEvent];
		}
		
		for(; i < [self.imageViews count]; i++) {
			
			IFImageView *imageView = [self.imageViews objectAtIndex:i];
			
			[str appendFormat:@"(%p) Rank %d %.3fM\n", imageView, i+1, ([imageView imageSize] / 1024) / 1024.0f];
			
			[imageView forceClearEvent];
		}
		
		if(str)
			self.report.text = str;
	}
	
	[self performSelector:@selector(check) withObject:nil afterDelay:0.1];
}

- (id)init {
	
	if(self = [super init]) {
		
		[self check];
	}
	
	return self;
}

- (void)IFImageFailed:(IFImageView *)imageView error:(NSError *)error {
	
	
}

- (void)IFImageLoaded:(IFImageView *)imageView image:(UIImage *)image {
	
	
}

- (NSMutableArray*)imageViews {
	
	if(!imageViews) {
		
		self.imageViews =
		(NSMutableArray*)
		CFArrayCreateMutable(NULL, 0,
							 &(const CFArrayCallBacks){0, NULL, NULL, NULL, NULL});   //&(what){the,fuck}?
	}
	
	return imageViews;
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

- (void)dealloc {
	
	self.imageViews = nil;
	
	[super dealloc];
}

@end
