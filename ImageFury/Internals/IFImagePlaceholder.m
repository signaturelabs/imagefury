//
//  IFImagePlaceholder.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFImagePlaceholder.h"


@interface IFImagePlaceholder ()

@property (nonatomic, assign) UIImageView *imageView;

@end


@implementation IFImagePlaceholder

@synthesize imageView;

- (id)initWithImage:(UIImage*)image {
	
	if(self = [super init]) {
		
		self.imageView =
		[[UIImageView alloc] initWithImage:image];
		
		imageView.backgroundColor = [UIColor grayColor];
		
		imageView.contentMode = self.contentMode;
		
		[self addSubview:imageView];
		[imageView release];
	}
	
	return self;
}

- (void)setContentMode:(UIViewContentMode)mode {
	
	[super setContentMode:mode];
	
	self.imageView.contentMode = mode;
}

- (void)setFrame:(CGRect)rect {
	
	[super setFrame:rect];
	
	rect.origin = CGPointZero;
	
	self.imageView.frame = rect;
}

- (UIView*)getPlaceholderGraphic:(UIView*)oldPlaceholderGraphic {
	
	return nil;
}

- (UIView*)getLoadingIndicator:(UIView*)oldLoadingIndicator progress:(NSNumber*)progress {
	
	return nil;
}

@end
