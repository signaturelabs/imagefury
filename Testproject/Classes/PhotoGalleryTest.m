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

#import "PhotoGalleryTest.h"
#import "IFImageView.h"
#import "CJSONDeserializer.h"
#import "FullscreenPhotosViewController.h"
#import "IFThrottle.h"

#include <stdlib.h>

@interface PhotoGalleryTest()

- (NSArray *)getImageUrlsFromTxtFile;
- (void)buildScrollView;
- (void)showFullScreenPhotoGallery;
- (int)getActivePhotoView;

@property (nonatomic, retain) NSArray *imageUrlStrings;

@end


@implementation PhotoGalleryTest

@synthesize scrollView, pageControl, imageUrlStrings;

#pragma mark -
#pragma mark IBAction

- (IBAction)fullScreenButtonPressed {
	[self showFullScreenPhotoGallery];
}

// set view frame for selected page
- (IBAction)pageControlAction {
	CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];	
}


- (IBAction)closeButtonPressed {
	[self dismissModalViewControllerAnimated:TRUE];
}


#pragma mark -
#pragma mark Private

-(int)getActivePhotoView {
	
	CGFloat x = self.scrollView.contentOffset.x;
	
	int i = 0;
	
	for(UIView *v in self.scrollView.subviews) {
		
		if(v.frame.origin.x > x)
			return i;
		
		i++;
	}
	
	return 0;
	
}

-(void)showFullScreenPhotoGallery {
	
	if(![self.scrollView.subviews count])
		return;
		
	NSMutableArray *imageViews = [[NSMutableArray alloc] init];
	for (NSString *urlString in self.imageUrlStrings) {
		
		IFImageView *imageView = [[IFImageView alloc] init];
		
		imageView.clipsToBounds = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		
		[imageView setURLString:urlString];
		[imageViews addObject:imageView];
		[imageView release];
	}
	
	FullscreenPhotosViewController *controller =
	[[FullscreenPhotosViewController alloc] initWithViews:imageViews];
	[imageViews release];
	
	IFImageView *activeView = [imageViews objectAtIndex:[self getActivePhotoView]];
	
	controller.activeView = activeView;
	
	controller.modalPresentationStyle = UIModalPresentationFullScreen;
	
	controller.delegate = self;
	
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
	//[activeView forceLoadEvent];
	
}

-(void)buildScrollView {
	for(UIView *v in scrollView.subviews) 
		[v removeFromSuperview];
	
	self.scrollView.contentSize =
	CGSizeMake(self.scrollView.frame.size.width * [imageUrlStrings count],
			   self.scrollView.frame.size.height);
	
	//set scrollView view frame for current image
    [self pageControlAction];
	
	CGRect imgFrame = CGRectZero;
	
	imgFrame.size = self.scrollView.frame.size;
	
	for(NSString *url in self.imageUrlStrings) {
		
		IFImageView *img = [[IFImageView alloc] init];
		
		img.clipsToBounds = YES;
		img.contentMode = UIViewContentModeScaleAspectFill;
		
		img.frame = CGRectInset(imgFrame, 20, 20);
		
		[img setURLString:url];
		
		[self.scrollView addSubview:img];
		[img release];
		
		imgFrame.origin.x += imgFrame.size.width;
	}
	
	// setting up PageControl
	if([self.imageUrlStrings count] > 0) {
		pageControl.numberOfPages = [self.imageUrlStrings count];
		pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
	}
}


- (NSArray *)getImageUrlsFromTxtFile {
	
	// our text file contains a JSON array of arrays, where each nested array is 
	// a list of image url strings.  parse JSON into 2d array, and then pick a random
	// nested array and display that group of images in the photo gallery.
	
	NSString *imageUrlsFile = [[NSBundle mainBundle] pathForResource:@"photo_gallery_urls" 
															  ofType:@"txt"];
	
	NSError *error;
	NSData *imageUrlsData = [NSData dataWithContentsOfFile:imageUrlsFile];
	
	NSArray	*imageUrlsNestedArray = [[CJSONDeserializer deserializer] deserializeAsArray:imageUrlsData 
																						error:&error];
	
	if ([imageUrlsNestedArray count] == 0) {
		NSLog(@"No image urls found!");
		return nil;
	}	
	
	// pick a random group of images in this array
	int r = rand() % [imageUrlsNestedArray count];
	
	return [imageUrlsNestedArray objectAtIndex:r];
	
}


#pragma mark -
#pragma mark ScrollViewDelegate

// set current page after scroll action
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	self.pageControl.currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}


#pragma mark -
#pragma mark ViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.imageUrlStrings = [self getImageUrlsFromTxtFile];

	[self buildScrollView];
	
	
	[IFThrottle shared].report = [[UITextView alloc] init];
	
	[IFThrottle shared].report.frame = CGRectMake(0, 0, 300, 300);
	
	[self.view addSubview:[IFThrottle shared].report];
	
	[IFThrottle shared].report.backgroundColor = [UIColor redColor];
}

- (void)dealloc {
	
	[IFThrottle shared].report = nil;
	
	self.scrollView = nil;
	self.pageControl = nil;
	self.imageUrlStrings = nil;
    [super dealloc];
}


@end
