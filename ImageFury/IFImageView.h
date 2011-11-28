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
 Traun Leyden <tleyden@signature-app.com>
 
 */

#import <UIKit/UIKit.h>
#import "IFLoader.h"
#import "IFPlaceholder.h"


enum IFImageViewState {
	IFImageViewStateCleared = 0,
	IFImageViewStateFired, // loading
	IFImageViewStateLoaded
};

@protocol IFImageViewDelegate;


@interface IFImageView : UIScrollView <UIScrollViewDelegate, IFLoaderDelegate> {

}

/// Calling this will cause the image to be added into the loading queue.
- (void)setURLString:(NSString*)url;

/// You can override this to set a custom placeholder for this instance.
/// Defaults to an instance of [[IFSettings shared] defaultPlaceholderClass].
/// Set to nil to disable the placeholder.
///
/// Note: Placeholders control the default graphic as well as loading
/// indicators.
@property (nonatomic, retain) IFPlaceholder *placeholder;

/// The overlay is only attached when the image loads successfully.
@property (nonatomic, retain) UIView *overlay;

/// Using the method will set a UIView overlay with the given settings.
/// You can use the following values for attachment get attach the image to
/// the corrisponding corner:
/// UIViewContentModeTopLeft
/// UIViewContentModeTopRight
/// UIViewContentModeBottomRight
/// UIViewContentModeBottomLeft
- (void)setOverlayImage:(UIImage*)image attachment:(UIViewContentMode)attachment;

/// Override this to set a custom timeout for this instance.
/// Defaults to [[IFSettings shared] defaultTimeout].
@property (nonatomic, assign) int requestTimeout;

/// Override this to set your own contentMode for this instance, to
/// control how the image is scaled on it's UIImageView, once loaded.
/// Defaults to UIViewContentModeScaleAspectFit.
@property (nonatomic, assign) UIViewContentMode contentMode;

// Set this to YES to enable pan and zoom.
@property (nonatomic, assign) BOOL panAndZoom;

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

/// This flags this instance as slightly less important than one
/// that is attached to a UIWindow.  Use this when you're worried
/// about how long it will take the image to appear.
@property (nonatomic, assign) BOOL important;

/// This forces the image view to be loaded right now.  Under most
/// scenarios you don't need to and shouldn't call this.
- (void)forceLoadEvent;

/// This cancels any download and hides the image, putting the
/// placeholder into a preload state.
- (void)forceClearEvent;

/// Returns an estimation of the amount of memory this instance is using
- (long long)imageSize;

/// Calculates this image views load priority
- (int)loadPriority;

/// The current state of the image view, cleared or fired.
@property (nonatomic, readonly) enum IFImageViewState state;

/// Returns a comparision result based on loadPriority
- (NSComparisonResult)compareTo:(IFImageView*)imageView;

/// Returns the reverse direction of compareTo
- (NSComparisonResult)reverseCompareTo:(IFImageView*)imageView;

/// Setting this property will cause the image to be resized according
/// to the frame size after it finishes loading
@property (nonatomic, assign) BOOL resizeAfterLoad;

/// Erases everything from the disk cache.
+ (void)clearCache;

+ (NSString*)getStoreageFilename:(NSURL*)url;

+ (void)installPreloadedCachedImages:(NSString*)preloadPath;

@end

@protocol IFImageViewDelegate<NSObject>
@optional

- (void)IFImageLoaded:(IFImageView*)imageView image:(UIImage*)image;
- (void)IFImageFailed:(IFImageView*)imageView error:(NSError*)error;

- (void)IFImageCanceled:(IFImageView*)imageView;

@end
