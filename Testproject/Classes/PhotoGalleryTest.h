//
//  PhotoGalleryTest.h
//  imagefury
//
//  Created by Traun Leyden on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoGalleryTest : UIViewController <UIScrollViewDelegate> {

}

@property (nonatomic, assign) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;

// set view frame for selected page
- (IBAction)pageControlAction;
- (IBAction)closeButtonPressed;
- (IBAction)fullScreenButtonPressed;

@end
