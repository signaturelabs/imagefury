//
//  IFTransitionGrow.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTransition.h"


@interface IFTransitionGrow : IFTransition {

}

- (void)setStartingRectFromView:(UIView*)view;
- (void)setStartingRect:(CGRect)rect;

@end
