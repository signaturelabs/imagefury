//
//  FullscreenPhotosViewController.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FullscreenPhotosDelegate<NSObject>
@optional

- (void)setSelectedIndex:(int)index;

@end


@interface FullscreenPhotosViewController : UIViewController<UIScrollViewDelegate> {

}

@property (nonatomic, assign) id<FullscreenPhotosDelegate> delegate;

/// Set this property before viewDidLoad fires, to be sure your image views are loaded in
@property (nonatomic, retain) NSArray *views; // UIView instances

/// If set, we will default the scroll to this view;
@property (nonatomic, assign) UIView *activeView;

@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet UIPageControl *pageControl;

@property (nonatomic, assign) IBOutlet UIToolbar *topBar;
@property (nonatomic, assign) IBOutlet UIToolbar *botBar;

- (id)initWithViews:(NSArray *)views;
- (IBAction)close;
- (IBAction)pageControlChanged;

@end
