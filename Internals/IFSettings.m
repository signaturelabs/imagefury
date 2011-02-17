//
//  ImageFury.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFSettings.h"
#import "IFPlaceholder.h"
#import "IFLoader.h"


@implementation IFSettings

@synthesize memUsage, diskCacheSize;
@synthesize maxActiveImages, defaultPlaceholderClass;
@synthesize defaultTimeout, cacheDirectory, tempCacheDirectory;

+ (IFSettings*)shared {
	
	static IFSettings *instance = 0;
	
	if(!instance)
		instance = [[IFSettings alloc] init];
	
	return instance;
}

- (void)trimDiskUse {
	
	[IFLoader trimDiskUse];
}

- (void)setCacheDirectory:(NSString *)str {
	
	[str retain];
	[cacheDirectory release];
	cacheDirectory = str;
	
	[[NSFileManager defaultManager]
	 createDirectoryAtPath:cacheDirectory
	 withIntermediateDirectories:YES
	 attributes:nil
	 error:nil];
	
	if(cacheDirectory)
		self.tempCacheDirectory =
		[NSString stringWithFormat:@"%@tempCacheDirectory/",
		 self.cacheDirectory];
	
	[self performSelector:@selector(trimDiskUse) withObject:nil afterDelay:0];
}

- (void)setTempCacheDirectory:(NSString *)str {
	
	[str retain];
	[tempCacheDirectory release];
	tempCacheDirectory = str;
	
	// Delete the temp directory.
	[[NSFileManager defaultManager]
	 removeItemAtPath:[self tempCacheDirectory]
	 error:nil];
	
	// Recreate it
	[[NSFileManager defaultManager]
	 createDirectoryAtPath:tempCacheDirectory
	 withIntermediateDirectories:YES
	 attributes:nil
	 error:nil];
	
	// No we got rid of all the unfinished objects
}

- (id)init {
	
	if(self = [super init]) {
		
		self.memUsage = 25 * 1024 * 1024;
		self.diskCacheSize = 100 * 1024 * 1024;
		self.maxActiveImages = 10;
		self.defaultPlaceholderClass = [IFPlaceholder class];
		self.defaultTimeout = 50;
		self.cacheDirectory =
		[NSString stringWithFormat:@"%@ImageFuryCache/",
		 NSTemporaryDirectory()];
	}
	
	return self;
}

- (void)dealloc {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	self.cacheDirectory = nil;
	self.tempCacheDirectory = nil;
	
	[super dealloc];
}

@end
