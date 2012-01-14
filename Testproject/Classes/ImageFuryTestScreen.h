//
//  ImageFuryTestScreen.h
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageFuryTestList.h"

@interface ImageFuryTestScreen : UIViewController<ImageFuryTestListDelegate>

/// Subclasses should attach their test to this view.
@property (nonatomic, readonly, retain) UIView *testView;

/// These methods should be overriden by subclasses
- (NSString*)title;
- (NSString*)purpose;
- (NSString*)result;
- (void)setup;
- (void)teardown;
/// Should return NO if failed, and YES if it succeeded or was indeterminate.
- (BOOL)runTest;

/// An array of Class objects representing subclasses of this class
/// that are to be in the test suite.
+ (NSMutableArray*)classes;

/// An array of Class objects that passed.
+ (NSMutableArray*)passed;

/// An array of Class objects that failed.
+ (NSMutableArray*)failed;

@end

/// This macro adds the class named 'className' to [ImageFuryTestScreen classes]
/// Use it for each subclass of ImageFuryTestScreen to add it to the test suite.
#define ADD_TEST_CLASS(className) \
  static void _addTestClass##className() __attribute__((constructor)); \
  static void _addTestClass##className() { \
    [[ImageFuryTestScreen classes] addObject:[className class]]; \
  }
