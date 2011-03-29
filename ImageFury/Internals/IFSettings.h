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

/// When a download fails, this image is shown in it's place.
@property (nonatomic, retain) UIImage *failedImagePlaceholder;

/// Disabled the background lazy loader.
@property (nonatomic, assign) BOOL debugMode;

@end
