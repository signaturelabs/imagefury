//
//  IFThrottle.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFImageView.h"


@interface IFThrottle : NSObject<IFImageViewDelegate> {

}

+ (IFThrottle*)shared;

/// Assign this property to a UITextView and IFThrottle will fill
/// it with debug information about the throttling.
@property (retain) UITextView *report;

- (void)add:(IFImageView*)imageView;
- (void)remove:(IFImageView*)imageView;

@end
