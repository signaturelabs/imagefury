    //
//  FullscreenPhotosViewController.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FullscreenPhotosViewController.h"
#import "IFThrottle.h"
#import <QuartzCore/QuartzCore.h>

@implementation FullscreenPhotosViewController

@synthesize delegate, views, scrollView, pageControl, activeView, topBar, botBar;

- (id)initWithViews:(NSArray *)theViews {
	if( (self=[super init] )) {

		self.views = theViews;
		
	}
	return self;
}

- (int)calcSelectedIndex {
	
	int div = (int)self.scrollView.frame.size.width;
	
	if(!div)
		return 0;
	
	return (int)self.scrollView.contentOffset.x / div;
}

- (IBAction)close {
	
	[self dismissModalViewControllerAnimated:NO];
}

- (IBAction)pageControlChanged {

	CGRect frame = scrollView.frame;
	
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];	
}

- (void)scrollViewDidScroll:(UIScrollView *)sv {
	
	if([self.delegate respondsToSelector:@selector(setSelectedIndex:)])
		[self.delegate setSelectedIndex:[self calcSelectedIndex]];
	
	pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

- (void)setupScrollView {
	
	for(UIView *view in self.scrollView.subviews)
		[view removeFromSuperview];
	
	if([self.views count]) {
		
		CGSize contentSize = CGSizeZero;
		CGRect cellRect = self.scrollView.frame;
		
		cellRect.origin = CGPointZero;
		
		//int colCount = ceil(sqrt([self.views count]));
		int colCount = [self.views count];
		int i = 0;
		
		self.scrollView.contentOffset = CGPointZero;
		self.pageControl.currentPage = 0;
		
		for(UIView *iv in self.views) {
			
			iv.clipsToBounds = TRUE;
			
			iv.frame = CGRectOffset(cellRect, cellRect.size.width * (i % colCount),
									cellRect.size.height * (i / colCount));
			
			//iv.contentMode = (kSuperFullScreen == TRUE) ? UIViewContentModeScaleAspectFill 
			//				: UIViewContentModeScaleAspectFit;
			
			contentSize.width = MAX(contentSize.width, CGRectGetMaxX(iv.frame));
			contentSize.height = MAX(contentSize.height, CGRectGetMaxY(iv.frame));
			
			if(iv == self.activeView) {
				
				self.scrollView.contentOffset = iv.frame.origin;
				self.pageControl.currentPage = iv.frame.origin.x / self.scrollView.frame.size.width;
			}
			
			// this looks ok on ipad, but border too big on iphone
			// iv.frame = CGRectInset(iv.frame, 60, 60);
			//iv.frame = CGRectInset(iv.frame, 5, 5);
			
			[self.scrollView addSubview:iv];
			
			i++;
		}
		
		self.scrollView.contentSize = contentSize;
		
		//self.pageControl.hidden = YES;
		self.pageControl.numberOfPages = contentSize.width / self.scrollView.frame.size.width;
	}
}

- (void)showBars {
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
	[self.topBar.layer removeAllAnimations];
	[self.botBar.layer removeAllAnimations];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	self.topBar.alpha = 0.85;
	self.botBar.alpha = 0.85;
	
	[UIView commitAnimations];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[self performSelector:@selector(hideBars) withObject:nil afterDelay:3];
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self setupScrollView];
	
	[self showBars];
	
	
	[IFThrottle shared].report = [[UITextView alloc] init];
	
	[IFThrottle shared].report.frame = CGRectMake(0, 50, 300, 300);
	
	[self.view addSubview:[IFThrottle shared].report];
	
	[IFThrottle shared].report.backgroundColor = [UIColor redColor];
}

- (void)viewDidUnload {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	[super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Fixes bug where the top bar ends up under the status bar.
	[self showBars];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
	[self setupScrollView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	return YES;
}

- (void)hideBars {
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	[self.topBar.layer removeAllAnimations];
	[self.botBar.layer removeAllAnimations];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	//[UIView setAnimationDuration:0.3];
	
	self.topBar.alpha = 0;
	self.botBar.alpha = 0;
	
	[UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(self.topBar.alpha > 0.1) {
		
		[self hideBars];
		return;
	}
	
	[self showBars];
}

- (void)dealloc {
	
	[IFThrottle shared].report = nil;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	self.views = nil;
	
	[super dealloc];
}

@end
