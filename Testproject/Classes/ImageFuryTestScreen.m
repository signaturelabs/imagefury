//
//  ImageFuryTestScreen.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageFuryTestScreen.h"

@interface ImageFuryTestScreen ()

@property (retain, nonatomic) IBOutlet UILabel *titleLbl;
@property (retain, nonatomic) IBOutlet UILabel *doesWhatLbl;
@property (retain, nonatomic) IBOutlet UILabel *resultLbl;

@property (retain, nonatomic) IBOutlet UIView *testView;

@end

@implementation ImageFuryTestScreen
@synthesize titleLbl;
@synthesize doesWhatLbl;
@synthesize resultLbl;
@synthesize testView;

- (void)dealloc {
    [titleLbl release];
    [doesWhatLbl release];
    [resultLbl release];
    [testView release];
    [super dealloc];
}

- (IBAction)fail:(id)sender {
    
    [self.class.passed removeObjectIdenticalTo:self.class];
    [self.class.failed removeObjectIdenticalTo:self.class];
    
    [self.class.failed addObject:self.class];
    
    [self teardown];
}

- (IBAction)pass:(id)sender {
    
    [self.class.passed removeObjectIdenticalTo:self.class];
    [self.class.failed removeObjectIdenticalTo:self.class];
    
    [self.class.passed addObject:self.class];
    
    [self teardown];
}

- (IBAction)start:(id)sender {
    
    [self setup];
    
    if(![self runTest])
        [self fail:nil];
}

- (NSString*)title {
    
    return @"Untitled";
}

- (NSString*)purpose {
    
    return @"";
}

- (NSString*)result {
    
    return @"";
}

- (void)setup { }
- (void)teardown { }
- (BOOL)runTest { return YES; }

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.titleLbl setText:self.title];
    [self.doesWhatLbl setText:self.purpose];
    [self.resultLbl setText:self.result];
}

+ (NSMutableArray*)classes {
    
    static NSMutableArray *ary = nil;
    
    if(!ary)
        ary = [NSMutableArray new];
    
    return ary;
}

+ (NSMutableArray*)passed {
    
    static NSMutableArray *ary = nil;
    
    if(!ary)
        ary = [NSMutableArray new];
    
    return ary;
}

+ (NSMutableArray*)failed {
    
    static NSMutableArray *ary = nil;
    
    if(!ary)
        ary = [NSMutableArray new];
    
    return ary;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload {
    [self setTitleLbl:nil];
    [self setDoesWhatLbl:nil];
    [self setResultLbl:nil];
    [self setTestView:nil];
    [super viewDidUnload];
}

@end
