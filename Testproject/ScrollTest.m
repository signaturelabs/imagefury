//
//  ScrollTest.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScrollTest.h"
#import "IFImageView.h"
#import "Webserver.h"

ADD_TEST_CLASS(ScrollTest);

@implementation ScrollTest

- (NSString*)title {
    
    return @"Scroll Test";
}

- (NSString*)purpose {
    
    return @"The purpose of this test is to see that images load correctly inside a scroll view";
}

- (NSString*)result {
    
    return @"You should be able to scroll down and see 9 images.";
}

- (void)setup {
    
    [IFImageView clearCache];
    
    UIScrollView *scroll = [UIScrollView new];
    
    NSArray *resources =
    [[NSDictionary dictionaryWithContentsOfURL:
     [NSBundle.mainBundle URLForResource:@"Images" withExtension:@"plist"]] objectForKey:@"images"];
    
    scroll.frame = self.testView.bounds;
    scroll.contentSize = (CGSize){scroll.frame.size.width, scroll.frame.size.height * resources.count};
    
    int i = 0;
    
    for(NSString *resource in resources) {
        
        IFImageView *iv = [IFImageView new];
        
        iv.frame = (CGRect){0, scroll.bounds.size.height * i++, scroll.bounds.size};
        
        [iv setURL:[Webserver.shared urlForResource:resource]];
        
        [scroll addSubview:iv];
        [iv release];
    }
    
    [self.testView addSubview:scroll];
}

@end
