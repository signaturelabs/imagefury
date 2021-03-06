/*
 ``The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/
 
 The Initial Developer of the Original Code is Hollrr, LLC.
 Portions created by the Initial Developer are Copyright (C) 2011
 the Initial Developer. All Rights Reserved.
 
 Contributor(s):
 
 Traun Leyden <tleyden@signature-app.com>
 
 */


#import <Foundation/Foundation.h>
#import "IFPlaceholder.h"

@interface IFColorPlaceholder : IFPlaceholder {

}

@property (nonatomic, retain) UIColor *color;

- (id)initWithColor:(UIColor *)color;


@end
