//
//  FailPlaceholderTest.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FailPlaceholderTest.h"
#import "IFImageView.h"
#import "Webserver.h"
#import "IFTextPlaceholder.h"

ADD_TEST_CLASS(FailPlaceholderTest)

@implementation FailPlaceholderTest

- (NSString*)title {
    
    return @"Placeholder Test";
}

- (NSString*)purpose {
    
    return @"The purpose of this test is to see that the placeholder appears after a failed image load";
}

- (NSString*)result {
    
    return @"You should see \"Placeholder\" below";
}

- (void)setup {
    
    [IFImageView clearCache];
    
    IFImageView *iv = [IFImageView new];
    
    iv.placeholder = [[IFTextPlaceholder alloc] initWithText:@"Placeholder" color:UIColor.blackColor];
    
    iv.frame = self.testView.bounds;
    
    [iv setURL:[Webserver.shared urlForResource:@"nonexistentresource.jpg"]];
    
    [self.testView addSubview:iv];
    [iv release];
}

@end
