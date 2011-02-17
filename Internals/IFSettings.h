//
//  ImageFury.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Use this singleton to set various settings used by ImageView.
@interface IFSettings : NSObject {

}

+ (IFSettings*)shared;

/// How much memory can we use before hidding images?
/// 0 means no limit.
@property (nonatomic, assign) int memUsage; // bytes

/// How big the disk cache can get before deleting stuff?
/// 0 means no limit.
@property (nonatomic, assign) int diskCacheSize; // bytes

/// How many images can we have active at once?
/// 0 means no limit.
@property (nonatomic, assign) int maxActiveImages;

/// What class should we use as the default placeholder / loading indicator?
@property (nonatomic, assign) Class defaultPlaceholderClass;

/// How long until we consider a request to have timed out?
@property (nonatomic, assign) int defaultTimeout; // seconds

/// What folder should we store our cache stuff in?
/// Needs to end in a slash.
@property (nonatomic, retain) NSString *cacheDirectory;

/// What folder should we store our temporary data in?
/// Setting 'cacheDirectory' automatically sets the value of this
/// property to be a subdirectory of 'cacheDirectory'.
/// Needs to end in a slash.
@property (nonatomic, retain) NSString *tempCacheDirectory;

@end
