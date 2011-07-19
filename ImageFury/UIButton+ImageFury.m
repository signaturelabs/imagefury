//
//  IFButton.m
//  associate
//
//  Created by Dustin Dettmer on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIButton+ImageFury.h"


/// Returns this btn's image view or creates a new one if it doesn't already exist
static IFImageView *imageViewForButton(void *btnPtr);

/// Pass a nil imageView to clear it.
static void setImageViewForButton(void *btnPtr, IFImageView *imageView);

@implementation UIButton (ImageFury)

- (void)IFImageLoaded:(IFImageView*)imageView image:(UIImage*)image {
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
    
    [self release];
    setImageViewForButton(self, nil);
    
}

- (void)IFImageFailed:(IFImageView*)imageView error:(NSError*)error {
    
    [self release];
    setImageViewForButton(self, nil);
}

- (void)IFImageCanceled:(IFImageView*)imageView {
    
    [self release];
    setImageViewForButton(self, nil);
}

- (void)setUrlRequest:(NSURLRequest*)urlRequest {
    
    [self retain];
    
    IFImageView *img = imageViewForButton(self);
    
    img.urlRequest = urlRequest;
}

- (void)setUrl:(NSURL*)url {
    
    [self setUrlRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setUrlString:(NSString*)url {
    
    [self setUrl:[NSURL URLWithString:url]];
}

@end

static NSMutableDictionary *dict = nil;

static IFImageView *imageViewForButton(void *btnPtr)
{
    if(!dict)
        dict = [[NSMutableDictionary alloc] init];
    
    NSValue *val = [NSValue valueWithPointer:btnPtr];
    
    IFImageView *ret = [dict objectForKey:val];
    
    if(!ret) {
        
        ret = [[IFImageView alloc] init];
        
        [ret addDelegate:btnPtr];
        
        setImageViewForButton(btnPtr, ret);
        
        [ret release];
    }
    
    return ret;
}

static void setImageViewForButton(void *btnPtr, IFImageView *imageView)
{
    NSValue *val = [NSValue valueWithPointer:btnPtr];
    
    if(imageView != nil)
        [dict setObject:imageView forKey:val];
    else
        [dict removeObjectForKey:val];
    
    if(![dict count]) {
        
        [dict release];
        dict = nil;
    }
}
