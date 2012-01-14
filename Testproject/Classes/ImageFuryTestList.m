//
//  ImageFuryTestList.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageFuryTestList.h"
#import "ImageFuryTestScreen.h"

@implementation ImageFuryTestList

@synthesize delegate;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ImageFuryTestScreen.classes.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"UITableViewCell"] autorelease];
    }
    
    cell.textLabel.textColor = UIColor.blackColor;
    
    Class c = [ImageFuryTestScreen.classes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = c.description;
    
    if([ImageFuryTestScreen.failed containsObject:c]) {
        
        cell.textLabel.textColor = UIColor.redColor;
    }
    
    if([ImageFuryTestScreen.passed containsObject:c]) {
        
        cell.textLabel.textColor = UIColor.greenColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class c = [ImageFuryTestScreen.classes objectAtIndex:indexPath.row];
    
    [self.delegate choseTestClass:c];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
