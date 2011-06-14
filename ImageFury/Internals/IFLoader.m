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

#import "IFLoader.h"
#import "IFSettings.h"

#define MAX_FILENAME_LENGTH 255


static long long diskUsageEstimate = 0;


@interface IFLoader ()

@property (nonatomic, retain) NSURLConnection *connection;

@property (nonatomic, assign) long long expectedContentLength;
@property (nonatomic, assign) long long contentOffset;

@property (nonatomic, assign) int requestNumber;

@property (assign) int updateCount;

- (NSString*)getStorageFilename;
- (NSString*)getTemporaryFilename;

@end


@implementation IFLoader

@synthesize urlRequest, running, delegate, cacheDir, tempCacheDir;
@synthesize connection, expectedContentLength, contentOffset;
@synthesize requestNumber, updateCount;

- (void)signalCompleted {
	
	[self.delegate IFLoaderComplete:[self getStorageFilename]];
}

- (BOOL)fileExists {
	
	return
	[[NSFileManager defaultManager]
	 fileExistsAtPath:[self getStorageFilename]];
}

- (void)setRunning:(BOOL)yesOrNo {
	
	if(running == yesOrNo)
		return;
	
	[IFLoader trimDiskUse];
	
	running = yesOrNo;
	
	if(!running) {
		
		if(self.connection)
			[[NSFileManager defaultManager]
			 removeItemAtPath:[self getStorageFilename]
			 error:nil];
		
		[self.connection cancel];
	}
	else {
		
		self.updateCount = 0;
		
		if([self fileExists]) {
			
			[self signalCompleted];
		}
		else {
			
			self.connection =
			[[[NSURLConnection alloc]
			  initWithRequest:self.urlRequest
			  delegate:self
			  startImmediately:YES] autorelease];
		}
	}
}

/// Requires 8 bit encoding type (ie UTF8)
- (NSString*)fullyEscapeString:(NSString*)str {
	
	NSMutableString *escaped = [NSMutableString string];
	
	for(int i = 0; i < [str length]; i++)
		[escaped appendFormat:@"%02X", [str characterAtIndex:i]];
	
	// If the filename is short enough, return it.
	if([escaped length] <= MAX_FILENAME_LENGTH)
		return escaped;
	
	// Add space for the SHA1 on the end
	NSString *shortened = [escaped substringToIndex:MAX_FILENAME_LENGTH - 20];
	
	// We just want to SHA1 the part we cut off
	const char *cStr =
	[[str substringFromIndex:MAX_FILENAME_LENGTH - 20] UTF8String];
	
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
	
    CC_SHA1(cStr, strlen(cStr), result);
	
	// This should be uppercase since the escape code above is uppercase.
    return
	[NSString  stringWithFormat:
	 @"%@%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X"
	  "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
	 shortened,
	 result[0],  result[1],  result[2],  result[3],
	 result[4],  result[5],  result[6],  result[7],
	 result[8],  result[9],  result[10], result[11],
	 result[12], result[13], result[14], result[15],
	 result[16], result[17], result[18], result[19]
	 ];
}

- (int)requestNumber {
	
	static int num = 0;
	
	if(!requestNumber)
		requestNumber = ++num;
	
	return requestNumber;
}

- (NSString*)getStorageFilename {
	
	NSString *safeStr =
	[self fullyEscapeString:[self.urlRequest.URL absoluteString]];
	
	return [NSString stringWithFormat:
			@"%@%@", self.cacheDir, safeStr];
}

- (NSString*)getTemporaryFilename {
	
	NSString *safeStr =
	[self fullyEscapeString:[self.urlRequest.URL absoluteString]];
	
	NSString *str = [NSString stringWithFormat:
			@"%@%@.%d.part", self.tempCacheDir, safeStr, [self requestNumber]];
	
	return str;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	[[NSFileManager defaultManager]
	 createFileAtPath:[self getTemporaryFilename]
	 contents:nil attributes:nil];
	
	self.expectedContentLength = [response expectedContentLength];
	self.contentOffset = 0;
}

- (void)sendProgressUpdate:(NSNumber*)progress {
	
	self.updateCount = self.updateCount + 1;
	
	[self.delegate IFLoaderProgress:(CGFloat)[progress doubleValue] updateCount:self.updateCount];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	NSFileHandle *fileHandle =
	[NSFileHandle fileHandleForWritingAtPath:
	 [self getTemporaryFilename]];
	
	[fileHandle seekToFileOffset:self.contentOffset];
	
	[fileHandle writeData:data];
	
	self.contentOffset += [data length];
	
	if(self.expectedContentLength != NSURLResponseUnknownLength)
		if([self.delegate respondsToSelector:@selector(IFLoaderProgress:updateCount:)]) {
			
			unsigned long long contentSize = [fileHandle seekToEndOfFile];
			
			double progress = (double)contentSize / self.expectedContentLength;
			
			[self
			 performSelectorOnMainThread:@selector(sendProgressUpdate:)
			 withObject:[NSNumber numberWithDouble:progress]
			 waitUntilDone:YES];
		}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	[[NSFileManager defaultManager]
	 removeItemAtPath:[self getTemporaryFilename] error:nil];
	
	if([self.delegate respondsToSelector:@selector(IFLoaderFailed:)])
		[self.delegate IFLoaderFailed:error];
	
	self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	[[NSFileManager defaultManager]
	 moveItemAtPath:[self getTemporaryFilename]
	 toPath:[self getStorageFilename]
	 error:nil];
	
	if(diskUsageEstimate)
		diskUsageEstimate += [[[NSFileManager defaultManager]
							   attributesOfItemAtPath:[self getStorageFilename]
							   error:nil]
							  fileSize];
	
	[self signalCompleted];
	
	self.connection = nil;
}

- (long long)fileSize {
	
	if(!self.connection && [self fileExists]) {
		
		NSFileHandle *fileHandle =
		[NSFileHandle fileHandleForReadingAtPath:
		 [self getStorageFilename]];
		
		long long ret = [fileHandle seekToEndOfFile];
		
		return ret;
	}
	
	return MAX(self.contentOffset, self.expectedContentLength);
}

+ (void)trimDiskUse {
	
	if([[IFSettings shared] diskCacheSize] == 0)
		return;
	
	if(diskUsageEstimate && diskUsageEstimate < [[IFSettings shared] diskCacheSize])
		return;
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSMutableArray *files =
	[NSMutableArray arrayWithArray:
	 [manager
	  contentsOfDirectoryAtPath:
	  [[IFSettings shared] cacheDirectory] error:nil]];
	
	NSMutableArray *modified = [NSMutableArray array];
	
	long long diskUse = 0;
	
	for(int i = 0; i < [files count]; i++) {
		
		NSString *path = [files objectAtIndex:i];
		
		path = 
		[NSString
		 stringWithFormat:@"%@%@",
		 [[IFSettings shared] cacheDirectory], path];
		
		NSDictionary *info = [manager attributesOfItemAtPath:path error:nil];
		
		if([info fileType] == NSFileTypeDirectory) {
			
			[files removeObjectAtIndex:i];
			
			i--;
			continue;
		}
		
		diskUse += [info fileSize];
		
		[modified addObject:[info fileModificationDate]];
	}
	
	int freeCount = 0;
	long long freedSpace = 0;
	
	while([[IFSettings shared] diskCacheSize] / 2 < diskUse) {
		
		if(![files count])
			break;
		
		NSDate *oldest = nil;
		int index = 0;
		
		for(int i = 0; i < [modified count]; i++) {
			
			NSDate *date = [modified objectAtIndex:i];
			
			if(!oldest || [oldest compare:date] == NSOrderedDescending) {
				
				oldest = date;
				index = i;
			}
		}
		
		if(!oldest)
			break;
		
		NSString *path = [files objectAtIndex:index];
		
		path = 
		[NSString
		 stringWithFormat:@"%@%@",
		 [[IFSettings shared] cacheDirectory], path];
		
		long long fileSize = [[manager attributesOfItemAtPath:path error:nil] fileSize];
		
		diskUse -= fileSize;
		freedSpace += fileSize;
		
		freeCount++;
		
		[manager removeItemAtPath:path error:nil];
		
		[files removeObjectAtIndex:index];
		[modified removeObjectAtIndex:index];
	}
	
	diskUsageEstimate = diskUse;
	
	if(freeCount)
		NSLog(@"Cleared %d cache items, freeing %.1f MB",
			  freeCount, (freedSpace / 1024) / 1024.0);
}

- (void)dealloc {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[self.connection cancel];
	
	self.connection = nil;
	self.urlRequest = nil;
	self.delegate = nil;
	self.cacheDir = nil;
	self.tempCacheDir = nil;
	
	[super dealloc];
}

@end
