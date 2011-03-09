//
//  IFImagePlaceholder.m
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFImagePlaceholder.h"


@implementation IFImagePlaceholder

@synthesize image;

- (id)init {
	
	return self = [super init];
}

- (id)initWithImage:(UIImage*)image {
	
	if(self = [super init]) {
		
		self.image = image;
	}
	
	return self;
}

- (UIView*)getPlaceholderGraphic:(UIView*)oldPlaceholderGraphic {
	
	if(!oldPlaceholderGraphic) {
		
		oldPlaceholderGraphic = [[UIImageView alloc] initWithImage:self.image];
		[oldPlaceholderGraphic autorelease];
	}
	
	return oldPlaceholderGraphic;
}

- (UIView*)getLoadingIndicator:(UIView*)oldLoadingIndicator progress:(NSNumber*)progress {
	
	return nil;
}

@end
