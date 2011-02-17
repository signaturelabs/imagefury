//
//  ImageFuryTest.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageFuryTest.h"
#import "IFPlaceholder.h"
#import "IFImageView.h"
#import "IFSettings.h"
#import "IFThrottle.h"


@interface ImageFuryTest ()

@property (nonatomic, retain) IFPlaceholder *ifPlaceholder;
@property (nonatomic, retain) IFLoader *ifLoader;
@property (nonatomic, retain) IFImageView *ifImageView;

@end

@implementation ImageFuryTest

@synthesize ifPlaceholder, ifLoader, ifImageView;

- (void)segmentChanged:(UISegmentedControl*)segment {
	
	if(segment.selectedSegmentIndex == 0)
		self.ifPlaceholder.state = IFPlaceholderStatePreload;
	if(segment.selectedSegmentIndex == 1)
		self.ifPlaceholder.state = IFPlaceholderStateLoading;
	if(segment.selectedSegmentIndex == 2)
		self.ifPlaceholder.state = IFPlaceholderStateFailed;
	if(segment.selectedSegmentIndex == 3)
		self.ifPlaceholder.state = IFPlaceholderStateSuccess;
}

- (void)performIFLoaderTest {
	
	self.ifLoader = [[[IFLoader alloc] init] autorelease];
	
	self.ifLoader.cacheDir = NSTemporaryDirectory();
	
	self.ifLoader.delegate = self;
	self.ifLoader.urlRequest =
	[NSURLRequest requestWithURL:
	 [NSURL URLWithString:@"http://www.google.com"]];
	
	self.ifLoader.running = YES;
}

- (void)absurdTest {
	
	static int i = 0;
	
	if(i > 100)
		i = 0;
	
	if(!i) {
		
		for(UIView *view in self.view.subviews)
			[view removeFromSuperview];
		
		[IFThrottle shared].report = [[UITextView alloc] init];
		
		[IFThrottle shared].report.frame = CGRectMake(0, 50, 300, 300);
		
		[self.view addSubview:[IFThrottle shared].report];
		
		[IFThrottle shared].report.backgroundColor =
		[UIColor colorWithWhite:1 alpha:0.5];
	}
	
	i++;
	
	[self.view bringSubviewToFront:[IFThrottle shared].report];
	
	NSString *url = @"http://www.google.com/logos/2011/valentines11-hp.jpg";
	
	IFImageView *imageView =
	[[IFImageView alloc] init];
	
	imageView.frame =
	CGRectMake(
		rand() % (int)self.view.frame.size.width - 100,
		rand() % (int)self.view.frame.size.height - 100,
		200,
		200
	);
	
	[imageView setURLString:
	 [NSString stringWithFormat:
	  @"%@",
	  url, 0]];
	 
	[self.view addSubview:imageView];
	[imageView release];
	
	[self performSelector:@selector(absurdTest) withObject:nil afterDelay:0.1];
}

- (void)clearCache {
	
	[IFImageView clearCache];
}

- (void)loadBigImage {
	
	self.ifImageView.urlRequest =
	[NSURLRequest requestWithURL:
	 [NSURL URLWithString:@"http://nyquil.org/uploads/IndianHeadTestPattern16x9.png"]];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.ifPlaceholder = [[[IFPlaceholder alloc] init] autorelease];
	
	self.ifPlaceholder.frame = CGRectMake(self.view.center.x / 2, 0, 400, 400);
	[self.view addSubview:self.ifPlaceholder];
	
	UISegmentedControl *segment =
	[[[UISegmentedControl alloc]
	  initWithItems:
	  [NSArray
	   arrayWithObjects:
	   @"Preloading",
	   @"Loading",
	   @"Failed",
	   @"Success",
	   nil]]
	  autorelease];
	
	segment.frame = CGRectMake(0, 0, 400, 50);
	segment.center = self.ifPlaceholder.center;
	segment.frame = CGRectOffset(segment.frame, 0, 250);
	
	[segment
	 addTarget:self
	 action:@selector(segmentChanged:)
	 forControlEvents:UIControlEventValueChanged];
	
	[self.view addSubview:segment];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	btn.frame = CGRectMake(5, 5, 150, 50);
	
	[btn setTitle:@"IFLoader Test" forState:UIControlStateNormal];
	
	[btn
	 addTarget:self
	 action:@selector(performIFLoaderTest)
	 forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btn];
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	btn.frame = CGRectMake(5, 55, 150, 50);
	
	[btn setTitle:@"Absurd Test" forState:UIControlStateNormal];
	
	[btn
	 addTarget:self
	 action:@selector(absurdTest)
	 forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btn];
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	btn.frame = CGRectMake(5, 105, 150, 50);
	
	[btn setTitle:@"Load Big Image" forState:UIControlStateNormal];
	
	[btn
	 addTarget:self
	 action:@selector(loadBigImage)
	 forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btn];
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	
	btn.frame = CGRectMake(5, 155, 150, 50);
	
	[btn setTitle:@"Clear cache" forState:UIControlStateNormal];
	
	[btn
	 addTarget:self
	 action:@selector(clearCache)
	 forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btn];
	
	self.ifImageView = [[[IFImageView alloc] init] autorelease];
	
	self.ifImageView.frame = CGRectMake(self.view.center.x - 350, 524, 700, 500);
	
	[self.ifImageView addDelegate:self];
	
	[self.view addSubview:self.ifImageView];
}

- (void)IFImageLoaded:(UIImage *)image {
	
}

- (void)IFImageFailed:(NSError *)error {
	
	UIAlertView *alert =
	[[UIAlertView alloc]
	 initWithTitle:@"IFImageFailed"
	 message:[error localizedDescription]
	 delegate:nil
	 cancelButtonTitle:@"Okay"
	 otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

- (void)viewDidUnload {
	
	self.ifPlaceholder = nil;
	
	self.ifLoader.delegate = nil;
	self.ifLoader = nil;
	
	[super viewDidUnload];
}

- (void)IFLoaderComplete:(NSString *)filename {
	
	NSError *error = nil;
	
	NSString *str =
	[NSString
	 stringWithContentsOfFile:filename
	 encoding:NSUTF8StringEncoding
	 error:&error];
	
	if(error)
		str = [error localizedDescription];
	
	UIAlertView *alert =
	[[UIAlertView alloc]
	 initWithTitle:filename
	 message:str
	 delegate:nil
	 cancelButtonTitle:@"Okay"
	 otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

- (void)IFLoaderFailed:(NSError *)error {
	
	UIAlertView *alert =
	[[UIAlertView alloc]
	 initWithTitle:@"IFLoaderFailed"
	 message:[error localizedDescription]
	 delegate:nil
	 cancelButtonTitle:@"Okay"
	 otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

@end
