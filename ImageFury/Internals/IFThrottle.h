/*
 ``The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/
 
 The Initial Developer of the Original Code is Hollrr, LLC.
 Portions created by the Initial Developer are Copyright (C) 2011
 the Initial Developer. All Rights Reserved.
 
 Contributor(s):
 
 Dustin Dettmer <dusty@dustytech.com>
 
 */


#import <Foundation/Foundation.h>
#import "IFImageView.h"


/// Maintains a list of all IFImageView instances and judges their
/// respective priorities.  The most important images are sent load
/// events while everyone lower on the list are sent unload events.
///
/// This keeps memory usage in check while keeping the most important
/// images readily available.
@interface IFThrottle : NSObject<IFImageViewDelegate> {

}

+ (IFThrottle*)shared;

/// Assign this property to a UITextView and IFThrottle will fill
/// it with debug information about the throttling.
@property (retain) UITextView *report;

- (void)add:(IFImageView*)imageView;
- (void)remove:(IFImageView*)imageView;

/// Sets a flag asking for a check to be performed soon.
/// The exact time of the check is tweaked to be most optimal,
/// typically occuring during view controller or view transitions. 
- (void)forceCheckSoon;

/// Performs a check now.
- (void)forceCheckNow;

/// Checks if there is an outstanding check soon request, if so it is
/// performed and cleared.
- (void)clearForceCheckQueue;

@end
