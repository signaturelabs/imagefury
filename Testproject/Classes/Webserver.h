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

@end
