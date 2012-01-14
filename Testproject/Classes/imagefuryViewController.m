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

#import "imagefuryViewController.h"
#import "ImageFuryTest.h"
#import "PhotoGalleryTest.h"
#import "IFThrottle.h"
#import "ImageFuryTestScreen.h"

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

- (IBAction)unitTests:(id)sender {
    
    ImageFuryTestScreen *controller = [[[ImageFuryTestScreen classes] objectAtIndex:0] new];
    
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
