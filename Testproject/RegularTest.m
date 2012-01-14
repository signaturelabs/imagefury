//
//  Regular.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegularTest.h"
#import "IFImageView.h"
#import "Webserver.h"

ADD_TEST_CLASS(RegularTest);

@implementation RegularTest

- (NSString*)title {
    
    return @"Regular Image Test";
}

- (NSString*)purpose {
    
    return @"The purpose of this test is to see that a basic image is loaded correctly.";
}

- (NSString*)result {
    
    return @"You should see an image discussing String Theory.";
}

- (void)setup {
    
    IFImageView *iv = [IFImageView new];
    
    iv.frame = self.testView.bounds;
    
    [iv setURL:[Webserver.shared urlForResource:@"stringtheory.jpg"]];
    
    [self.testView addSubview:iv];
    [iv release];
}

@end
