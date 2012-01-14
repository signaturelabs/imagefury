//
//  Error403Test.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Error403Test.h"
#import "IFImageView.h"
#import "Webserver.h"

ADD_TEST_CLASS(Error403Test)

@implementation Error403Test

- (NSString*)title {
    
    return @"Error 403 Test";
}

- (NSString*)purpose {
    
    return @"The purpose of this test is to simulate an intermittent 403 error.";
}

- (NSString*)result {
    
    return @"You should see two image squares below.  One should fail to load while the other "
    " should show a picture with the phrase WHEEEEEEEE";
}

- (void)addImage:(BOOL)firstImage {
    
    [IFImageView clearCache];
    
    CGRect frame = self.testView.bounds;
    
    frame.size.width /= 2;
    
    if(!firstImage)
        frame.origin.x += frame.size.width;
    
    IFImageView *iv = [IFImageView new];
    
    iv.frame = frame;
    
    if(firstImage)
       [iv addDelegate:self];
    
    [iv setURL:[Webserver.shared urlForResource:@"duty_calls.png" parameters:@"intermittent403=1"]];
    
    [self.testView addSubview:iv];
    [iv release];
}

- (void)setup {
    
    [self addImage:YES];
}

- (void)IFImageLoaded:(IFImageView *)imageView image:(UIImage *)image {
    
    [self addImage:NO];
}

- (void)IFImageFailed:(IFImageView *)imageView error:(NSError *)error {
    
    [self addImage:NO];
}

@end
