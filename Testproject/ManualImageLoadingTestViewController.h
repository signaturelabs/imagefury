//
//  ManualImageLoadingTestViewController.h
//  imagefury
//
//  Created by andertsk on 05.09.11.
//  Copyright 2011 vEkaSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFImageView.h"

@interface ManualImageLoadingTestViewController : UIViewController {
	IBOutlet IFImageView	*imgView;
	IBOutlet UITextView		*textView;
	IBOutlet UILabel		*urlLabel;
	IBOutlet UILabel		*timeLabel;
	int	currentIndex;
	int randSeconds;
	NSTimer *timer;
}

@property (nonatomic, retain) NSTimer *timer;

-(IBAction)loadNext;
-(IBAction)loadSequenceWithRandomTiming;
-(IBAction)cancelPressed;

@end