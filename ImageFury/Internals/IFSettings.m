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


#import "IFSettings.h"
#import "IFPlaceholder.h"
#import "IFLoader.h"


@implementation IFSettings

@synthesize memUsage, diskCacheSize;
@synthesize maxActiveImages, maxLoadingImages, defaultPlaceholderClass;
@synthesize defaultTimeout, cacheDirectory, tempCacheDirectory;
@synthesize failedImagePlaceholder;
@synthesize debugMode;

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
		self.maxActiveImages = 25;
        self.maxLoadingImages = 4   ;
		self.defaultPlaceholderClass = [IFPlaceholder class];
		self.defaultTimeout = 50;
		self.failedImagePlaceholder = [UIImage imageNamed:@"IFBrokenDownload.png"];
		self.cacheDirectory =
		[NSString stringWithFormat:@"%@ImageFuryCache/",
		 NSTemporaryDirectory()];
		
		self.debugMode = NO;
	}
	
	return self;
}

- (void)dealloc {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	self.cacheDirectory = nil;
	self.tempCacheDirectory = nil;
	self.failedImagePlaceholder = nil;
	
	[super dealloc];
}

@end
