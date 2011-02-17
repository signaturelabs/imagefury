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
 Traun Leyden <tleyden@hollrr.com> 
 */


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
