//
//  IncompleteTest.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IncompleteTest.h"
#import "IFImageView.h"
#import "Webserver.h"

ADD_TEST_CLASS(IncompleteTest)

@implementation IncompleteTest

- (NSString*)title {
    
    return @"Incomplete Image Test";
}

- (NSString*)purpose {
    
    return @"The purpose of this test is to simulate an incomplete image load.";
}

- (NSString*)result {
    
    return @"You should see an image that has only loaded about halfway.";
}

- (void)setup {
    
    IFImageView *iv = [IFImageView new];
    
    iv.frame = self.testView.bounds;
    
    [iv setURL:[Webserver.shared urlForResource:@"labyrinth.png" parameters:@"incomplete=1"]];
    
    [self.testView addSubview:iv];
    [iv release];
}

@end
