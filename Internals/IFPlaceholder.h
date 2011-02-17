//
//  IFPlaceholder.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
