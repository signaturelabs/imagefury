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

- (void)setUrlRequest:(NSURLRequest*)urlRequest;
- (void)setUrl:(NSURL*)url;
- (void)setUrlString:(NSString*)url;

@end
