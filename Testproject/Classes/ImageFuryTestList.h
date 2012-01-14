//
//  ImageFuryTestList.h
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ImageFuryTestList;

@protocol ImageFuryTestListDelegate <NSObject>

- (void)choseTestClass:(Class)classObj;

@end

@interface ImageFuryTestList : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) id<ImageFuryTestListDelegate> delegate;

@end
