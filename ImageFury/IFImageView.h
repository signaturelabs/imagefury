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

#import <UIKit/UIKit.h>
#import "IFLoader.h"
#import "IFPlaceholder.h"


enum IFImageViewState {
	IFImageViewStateCleared = 0,
	IFImageViewStateFired,
	IFImageViewStateLoaded
};

@protocol IFImageViewDelegate;


@interface IFImageView : UIView<IFLoaderDelegate> {

}

/// Calling this will cause the image to be added into the loading queue.
- (void)setURLString:(NSString*)url;

/// You can override this to set a custom placeholder for this instance.
/// Defaults to an instance of [[ImageFury shared] defaultPlaceholderClass].
/// Set to nil to disable the placeholder.
///
/// Note: Placeholders control the default graphic as well as loading
/// indicators.
@property (nonatomic, retain) IFPlaceholder *placeholder;

/// Override this to set a custom timeout for this instance.
/// Defaults to [[ImageFury shared] defaultRequestTimeout].
@property (nonatomic, assign) int requestTimeout;

/// Override this to set your own contentMode for this instance, to
/// control how the image is scaled on it's UIImageView, once loaded.
/// Defaults to [[ImageFury shared] defaultContentMode].
@property (nonatomic, assign) UIViewContentMode contentMode;

/// Calling this will cause the image to be added into the loading queue.
- (void)setURL:(NSURL*)url;

/// Setting this property will cause the item to be added into the
/// loading queue.  This is the lower-level, more raw access.  Both
/// setUrl and setURLString work by setting this property.
@property (nonatomic, retain) NSURLRequest *urlRequest;

/// Pass object here to have it be called as a delegate would.
/// Warning: Call removeDelegate when the delegate object is released
/// and / or inside it's dealloc.  Failure to do so will result
/// in crashes.
- (void)addDelegate:(id<IFImageViewDelegate>)delegate;

/// You *must* call removeDelegate when the delegate
/// is released / dealloced / gone.
- (void)removeDelegate:(id<IFImageViewDelegate>)delegate;

/// This forces the image view to be loaded right now.  Under most
/// scenarios you don't need to and shouldn't call this.
- (void)forceLoadEvent;

/// This cancels any download and hides the image, putting the
/// placeholder into a preload state.
- (void)forceClearEvent;

/// Returns out estimation for the amount of memory this instance is using
- (long long)imageSize;

/// Calculates this image views load priority
- (int)loadPriority;

/// The current state of the image view, cleared or fired.
@property (nonatomic, readonly) enum IFImageViewState state;

/// Returns a comparision result based on loadPriority
- (NSComparisonResult)compareTo:(IFImageView*)imageView;

/// Returns the reverse direction of compareTo
- (NSComparisonResult)reverseCompareTo:(IFImageView*)imageView;

/// Erases everything from the disk cache.
+ (void)clearCache;

@end

@protocol IFImageViewDelegate<NSObject>
@optional

- (void)IFImageLoaded:(IFImageView*)imageView image:(UIImage*)image;
- (void)IFImageFailed:(IFImageView*)imageView error:(NSError*)error;

@end