//
//  SlowTest.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlowTest.h"
#import "IFImageView.h"
#import "Webserver.h"

ADD_TEST_CLASS(SlowTest)

@implementation SlowTest

- (NSString*)title {
    
    return @"Slow Image Test";
}

- (NSString*)purpose {
    
    return @"The purpose of this test is to simulate slow internet.";
}

- (NSString*)result {
    
    return @"You should see an image with the phrase \"My Code's Compiling\" after a long delay.";
}

- (void)setup {
    
    IFImageView *iv = [IFImageView new];
    
    iv.frame = self.testView.bounds;
    
    [iv setURL:[Webserver.shared urlForResource:@"compiling.png" parameters:@"slow=1"]];
    
    [self.testView addSubview:iv];
    [iv release];
}

@end
