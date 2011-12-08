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

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@protocol IFLoaderDelegate<NSObject>

- (void)IFLoaderComplete:(NSString*)filename;

@optional

- (void)IFLoaderFailed:(NSError*)error;
- (void)IFLoaderProgress:(CGFloat)progress updateCount:(int)updateCount;

@end


@interface IFLoader : NSObject {

}

/// By default, if loader rejects anything whose mime type doesnt
/// start with "image/".  Disable this behavior by setting this flag to YES.
@property (nonatomic, assign) BOOL allowNonImages;

/// By default, if a http header tag called "ETag" is found in the response,
/// we confirm the checksums match and throw out the result if they do not.
/// Disable this behavior by setting this flag to YES.
@property (nonatomic, assign) BOOL allowChecksumFailure;

@property (nonatomic, retain) NSURLRequest *urlRequest;

/// Set to YES to begin the url request.
/// Set to NO to cancel the request.
/// Note: Due to NSURLRequest retaining this class, you must set
/// running to NO to release this instance in a timely manner
@property (nonatomic, assign) BOOL running;

@property (assign) id<IFLoaderDelegate> delegate;

/// This must be set to the name of a valid writable directory.
@property (nonatomic, retain) NSString *cacheDir;

/// This must be set to the name of a valid writable directory.
@property (nonatomic, retain) NSString *tempCacheDir;

/// Returns 0 if the fileSize is not known.
@property (nonatomic, readonly) long long fileSize;

/// Returns true if the file is already stored in cache and is non zero.
- (BOOL)nonEmptyFileExists;

/// Checks if the disk usage is over [[IFThrottle shared] diskCacheSize]
/// bytes and removes cache items (based on timestamp) until we're under
/// the usage size again.
+ (void)trimDiskUse;

+ (NSString*)getStoreageFilename:(NSURL*)url cacheDir:(NSString*)cacheDir;

@end
