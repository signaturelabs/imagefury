//
//  ImageFuryTestScreen.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageFuryTestScreen.h"
#import "IFImageView.h"

@interface ImageFuryTestScreen ()

@property (retain, nonatomic) IBOutlet UILabel *titleLbl;
@property (retain, nonatomic) IBOutlet UILabel *doesWhatLbl;
@property (retain, nonatomic) IBOutlet UILabel *resultLbl;

@property (retain, nonatomic) IBOutlet UIView *testView;

@property (nonatomic, retain) UIPopoverController *popCntrl;

@property (nonatomic, assign) BOOL active;

@end

@implementation ImageFuryTestScreen
@synthesize titleLbl;
@synthesize doesWhatLbl;
@synthesize resultLbl;
@synthesize testView;
@synthesize popCntrl;
@synthesize active;

- (void)dealloc {
    
    [titleLbl release];
    [doesWhatLbl release];
    [resultLbl release];
    [testView release];
    
    [popCntrl dismissPopoverAnimated:NO];
    [popCntrl release];
    popCntrl = nil;
    
    [super dealloc];
}

- (id)init {
    
    return (self = [super initWithNibName:@"ImageFuryTestScreen" bundle:nil]);
}

- (void)choseTestClass:(Class)classObj {
    
    if(self.active)
        [self teardown];
    
    self.active = NO;
    
    UIViewController *presenter = self.parentViewController ? self.parentViewController : self.presentingViewController;
    
    [self dismissModalViewControllerAnimated:NO];
    
    UIViewController *controller = [classObj new];
    
    [presenter presentModalViewController:controller animated:NO];
    [controller release];
}

- (void)next {
    
    NSInteger index = [self.class.classes indexOfObject:self.class] + 1;
    
    if(index < self.class.classes.count) {
        
        [self choseTestClass:[self.class.classes objectAtIndex:index]];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finished"
                                                        message:@"You've finished the last unit test"
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (IBAction)close:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)fail:(id)sender {
    
    [self.class.passed removeObjectIdenticalTo:self.class];
    [self.class.failed removeObjectIdenticalTo:self.class];
    
    [self.class.failed addObject:self.class];
    
    [self teardown];
    
    self.active = NO;
    
    [self next];
}

- (IBAction)pass:(id)sender {
    
    [self.class.passed removeObjectIdenticalTo:self.class];
    [self.class.failed removeObjectIdenticalTo:self.class];
    
    [self.class.passed addObject:self.class];
    
    [self teardown];
    
    self.active = NO;
    
    [self next];
}

- (IBAction)start:(id)sender {
    
    [IFImageView clearCache];
    
    if(self.active)
        [self teardown];
    
    self.active = YES;
    
    [self setup];
    
    if(![self runTest]) {
        
        [self fail:nil];
    }
}

- (IBAction)tests:(UIBarButtonItem*)sender {
    
    ImageFuryTestList *controller = [ImageFuryTestList new];
    
    controller.delegate = self;
    
    [self.popCntrl dismissPopoverAnimated:NO];
    
    self.popCntrl =
    [[UIPopoverController alloc] initWithContentViewController:controller];
    [controller release];
    
    [self.popCntrl presentPopoverFromBarButtonItem:sender
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
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

- (void)teardown {
    
    for(UIView *v in self.testView.subviews)
        [v removeFromSuperview];
}

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
