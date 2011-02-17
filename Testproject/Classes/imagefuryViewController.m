//
//  imagefuryViewController.m
//  imagefury
//
//  Created by Traun Leyden on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "imagefuryViewController.h"
#import "ImageFuryTest.h"
#import "PhotoGalleryTest.h"
#import "IFThrottle.h"

@implementation imagefuryViewController

- (IBAction) imageFuryTetsButtonPressed {
	
	ImageFuryTest *controller = [[ImageFuryTest alloc] init];
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
		
}

- (IBAction) scrollButtonPressed {
	
	PhotoGalleryTest *controller = [[PhotoGalleryTest alloc] init];
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
	
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
