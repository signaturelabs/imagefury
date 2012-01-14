//
//  Webserver.h
//  imagefury
//
//  Created by Dustin Dettmer on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEBSERVER_PORT "1234"

@interface Webserver : NSObject

+ (Webserver*)shared;

/// Returns a url to load from the local webserver for 'resourceName'.
- (NSURL*)urlForResource:(NSString*)resourceName;
- (NSURL*)urlForResource:(NSString*)resourceName parameters:(NSString*)parameters;

@end
