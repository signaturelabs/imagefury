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


typedef enum IFPlaceholderState {
	
	IFPlaceholderStatePreload = 0,
	IFPlaceholderStateLoading,
	IFPlaceholderStateFailed,
	IFPlaceholderStateSuccess,
	
} IFPlaceholderState;

@interface IFPlaceholder : UIView {

}

/// This property is set for transitions between states
@property (nonatomic, assign) IFPlaceholderState state;

/// This method is called with the current progress.
/// Subclassers don't need to override this method, instead
/// use the 'progress' parameter to getLoadingIndicator.
- (void)setProgress:(CGFloat)progress;

/// Returns a gray rectangle.  Subclassers should override this and return
/// the graphic of their choosing.
- (UIView*)getPlaceholderGraphic:(UIView*)oldPlaceholderGraphic;

/// Returns an animating UIActivityIndicatorView view hierarchy.  Subclassers
/// should override this and return the graphic of their choosing.
/// If progress is not NULL, it represents how far along the loading state is.
/// It's floatValue is 0 to begin and gets to 1 when it's done.
- (UIView*)getLoadingIndicator:(UIView*)oldLoadingIndicator progress:(NSNumber*)progress;

@end
