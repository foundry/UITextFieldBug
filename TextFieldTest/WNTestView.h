//
//  WNTestView.h
//  TextFieldTest
//
//  Created by jonathan on 08/10/2015.
//  Copyright © 2015 foundry. All rights reserved.
//

@import UIKit;

@interface WNTestView : UIView  <UITextFieldDelegate>
@property (nonatomic, strong) UITextField* textField1;
@property (nonatomic, strong) UITextField* textField2;
@property (nonatomic, assign, readwrite) CGFloat keyboardHeight;

@end
