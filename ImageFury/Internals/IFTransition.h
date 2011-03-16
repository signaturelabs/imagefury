//
//  IFTransitionViewController.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IFTransition : NSObject {

}

/// Screenshot of the controller we're going to.  This screenshot will be
/// generated inside 'start'.  Since the screenshot is a performance heavy
/// operation, it is recomended you set customToImage instead.
///
/// toImage is unused if 'customToImage' is set.
@property (nonatomic, readonly, retain) UIImageView *toImage;

/// Set this to the UIView that represents the toImage view
/// Using this property is more optimized 
@property (nonatomic, retain) UIView *customToImage;

@property (nonatomic, readonly, retain) UIViewController *fromController;
@property (nonatomic, readonly, retain) UIViewController *toController;

@property (nonatomic, assign) BOOL reverse;

- (id)initWithModalTransitionFrom:(UIViewController*)controller to:(UIViewController*)destination;
- (id)initWithNavigationTransitionFrom:(UIViewController*)controller to:(UIViewController*)destination;

/// Starts up the transition effect.  Subclasses must call this method to start properly.
- (void)start;

/// Finishes the transition effect.  Subclasses must call this method to end properly.
/// 
/// finish need not be called by users of the class, as subclasses will call it at
/// the end of their transition animation.
- (void)finish;

/// Returns the customToImage if set and the toImage otherwise.
- (UIView*)getToImageView;

/// Calculates the origin of 'view' taking into account all of its
/// superviews (including UIScrollViews and their scroll positions).
+ (CGPoint)absoluteOrigin:(UIView*)view;

@end
