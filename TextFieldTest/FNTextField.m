//
//  FNTextField.m
//  TextFieldTest
//
//  Created by jonathan on 08/07/2016.
//  Copyright © 2016 foundry. All rights reserved.
//

#import "FNTextField.h"

@implementation FNTextField
- (BOOL)resignFirstResponder    {
    BOOL result = [super resignFirstResponder];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return result;
}
@end
