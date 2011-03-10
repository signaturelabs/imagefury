//
//  IFTransitionViewController.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IFTransition : UIViewController {

}

/// Screenshot of the controller we're coming from
@property (nonatomic, readonly, retain) UIImageView *fromImage;

/// Screenshot of the controller we're going to
@property (nonatomic, readonly, retain) UIImageView *toImage;

@property (nonatomic, readonly, retain) UIViewController *fromController;
@property (nonatomic, readonly, retain) UIViewController *toController;

- (id)initWithModalTransitionFrom:(UIViewController*)controller to:(UIViewController*)destination;
- (id)initWithNavigationTransitionFrom:(UIViewController*)controller to:(UIViewController*)destination;

/// Starts up the transition effect.  Subclasses must call this method to start properly.
- (void)start;

/// Finishes the transition effect.  Subclasses must call this method to end properly.
/// 
/// finish need not be called by users of the class, as subclasses will call it at
/// the end of their transition animation.
- (void)finish;

@end
