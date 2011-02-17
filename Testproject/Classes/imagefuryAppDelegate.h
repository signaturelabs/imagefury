//
//  imagefuryAppDelegate.h
//  imagefury
//
//  Created by Traun Leyden on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class imagefuryViewController;

@interface imagefuryAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    imagefuryViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet imagefuryViewController *viewController;

@end

