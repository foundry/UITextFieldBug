//
//  WNTestView.h
//  TextFieldTest
//
//  Created by jonathan on 08/10/2015.
//  Copyright © 2015 foundry. All rights reserved.
//

/*
 update 10 July 2016 - suggested bug fix
 */


/*
 
 these are simple attempts to animate text fields as the keyboard slides up
 comparisions with autolayout and frame-setting methods
 there are no animation blocks - animation is handled 'implicitly' by the keyboard animation.
 
 different environments to test
 
 USE_AUTOLAYOUT ON   USE_AUTOLAYOUT OFF
 
 1/ simulator, ios 8.4        no issue             no issue
 2/ simulater, ios 9.0          bug                no issue
 3/ device, ios 9.0             bug                no issue
 
 bug is only manifest on first run after view initialisation
 to see the bug
 1. start entering text in first text field
 - keyboard will animate up
 - text entry will work as usual
 2. now start entering text in second text field
 - text in first text field will jump up momentarily.
 This _looks_ as if a CAAnimation stack has some unfinished animations but may be caused by something entirely different. I have tried to 'removeAllAnimations' from all layers etc but not managed to isolate the cause.
 
 There is a probaly-related NSLayoutConstraint conflict warning involving UIRemoteKeyboardWindow and
 UIInputSetContainerView (noted below).
 */



#define SLIDE_UP_TEXTFIELDS //bug is manifest whether or not we need to slide up the textfields when the keyboard appears

#define USE_AUTOLAYOUT  //bug is only manifest when using autolayout. Frame-based textFields do not show the bug.

#define BUG_FIX //bug is fixed by sending 'setNeedsLayout' and 'layoutIfNeeded' to a UITextField subclass on resignFirstResponder


@import UIKit;

@interface FNView : UIView  <UITextFieldDelegate>
@property (nonatomic, strong) UITextField* textField1;
@property (nonatomic, strong) UITextField* textField2;
@property (nonatomic, assign, readwrite) CGFloat keyboardHeight;

@end
