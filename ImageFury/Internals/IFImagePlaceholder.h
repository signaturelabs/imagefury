//
//  IFImagePlaceholder.h
//  associate.ipad
//
//  Created by Dustin Dettmer on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFPlaceholder.h"


@interface IFImagePlaceholder : IFPlaceholder {

}

- (id)init;

- (id)initWithImage:(UIImage*)image;

@property (nonatomic, retain) UIImage *image;

@end
