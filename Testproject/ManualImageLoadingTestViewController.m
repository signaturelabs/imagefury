    //
//  ManualImageLoadingTestViewController.m
//  imagefury
//
//  Created by andertsk on 05.09.11.
//  Copyright 2011 vEkaSoft. All rights reserved.
//

#import "ManualImageLoadingTestViewController.h"

#define LIST_KEY @"IMG_ADDRESS_LIST"
#define DEFAULT_TEST_DATA @"http://profile.ak.fbcdn.net/hprofile-ak-snc4/70920_506407422_3804915_n.jpg\n\nnil\n\nhttp://profile.ak.fbcdn.net/hprofile-ak-snc4/174317_100001067719639_7762941_n.jpg\n\nhttp://profile.ak.fbcdn.net/hprofile-ak-snc4/275224_2419572_4517444_n.jpg\n\nnil\n\nnil"
#define DEFAULT_DELAY_MAX 15

@implementation ManualImageLoadingTestViewController

@synthesize timer;

#pragma mark URL list model
//returns next url in sequence or nil for last one
-(NSString*)getNextURL {
	NSArray *urlList = [NSArray arrayWithArray:[textView.text componentsSeparatedByString:@"\n"]];
	
	if (currentIndex >= [urlList count]) 
		return nil;
	
	NSString *urlStr = [urlList objectAtIndex:currentIndex];
	currentIndex++;
	if([urlStr length] > 0)
		return urlStr;
	else 
		return [self getNextURL];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		currentIndex = 0;
		[self loadNext];
	}		
}

#pragma mark actions
// load image and update url label
-(void)loadImageWithUrlStr:(NSString*)urlStr {
	urlLabel.text = urlStr;
	[imgView setURLString:urlStr];	
}

// load next url action
-(IBAction)loadNext {
	NSString *urlStr = [self getNextURL];
	
	if (urlStr != nil) {
		[self loadImageWithUrlStr:urlStr];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're done"
														message:@"Would you like to start over?"
													   delegate:self
											  cancelButtonTitle:@"NO"
											  otherButtonTitles:@"YES", nil];
		[alert show];
		[alert release];
	}
}

#pragma mark Load URL sequence with delay
// load sequence url timer. counts seconds and fire loading.
- (void)timerFireMethod:(NSTimer*)theTimer {
	randSeconds--;
	if(randSeconds > 0) {
		// if stil counting - update time label
		timeLabel.text = [NSString stringWithFormat:@"Loading URL: %d", randSeconds];
	}
	else {
		// if current counting is over
		timeLabel.text = @"Loading URL:";
		NSString *urlStr = [self getNextURL];
		
		if (urlStr != nil) {
			// load next image and start counting for next one
			[self loadImageWithUrlStr:urlStr];
			randSeconds = (arc4random()%DEFAULT_DELAY_MAX + 1);
		}
		else {
			// clear after last url
			currentIndex = 0;
			[theTimer invalidate];
		}
	}
}

-(IBAction)loadSequenceWithRandomTiming {
	currentIndex = 0;
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 
												  target:self 
												selector:@selector(timerFireMethod:) 
												userInfo:nil
												 repeats:YES];
}

-(IBAction)cancelPressed {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark viewController stuff
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	textView.text = [[NSUserDefaults standardUserDefaults] valueForKey:LIST_KEY];
	urlLabel.text = @"None";
	currentIndex = 0;
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSUserDefaults standardUserDefaults] setValue:textView.text forKey:LIST_KEY];
	if([timer isValid])
		[timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if([[NSUserDefaults standardUserDefaults] valueForKey:LIST_KEY] == nil)
		[[NSUserDefaults standardUserDefaults] setValue:DEFAULT_TEST_DATA forKey:LIST_KEY];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[timer release];
    [super dealloc];
}

@end