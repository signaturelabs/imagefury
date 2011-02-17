//
//  IFLoader.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol IFLoaderDelegate<NSObject>

- (void)IFLoaderComplete:(NSString*)filename;

@optional

- (void)IFLoaderFailed:(NSError*)error;
- (void)IFLoaderProgress:(CGFloat)progress updateCount:(int)updateCount;

@end


@interface IFLoader : NSObject {

}

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

/// Checks if the disk usage is over [[IFThrottle shared] diskCacheSize]
/// bytes and removes cache items (based on timestamp) until we're under
/// the usage size again.
+ (void)trimDiskUse;

@end
