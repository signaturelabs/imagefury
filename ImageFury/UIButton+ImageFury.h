//
//  IFButton.h
//  associate
//
//  Created by Dustin Dettmer on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFImageView.h"

@interface UIButton (ImageFury) <IFImageViewDelegate>

/// These methods set the backgroundImage for UIControlStateNormal,
/// after loading the given image data.  If you require additional loading
/// and behavior control, put an IFImageView ontop of the button.
- (void)setUrlRequest:(NSURLRequest*)urlRequest;
- (void)setUrl:(NSURL*)url;
- (void)setUrlString:(NSString*)url;

@end
