//
//  WNTestView.m
//  TextFieldTest
//
//  Created by jonathan on 08/10/2015.
//  Copyright © 2015 foundry. All rights reserved.
//  develop@foundry.tv

#import "FNView.h"
#import "FNTextField.h"

@interface FNView()
@property (nonatomic, strong) UIView* spacer1;
@property (nonatomic, strong) UIView* spacer2;
@property (nonatomic, assign) CGRect frameRect1;
@property (nonatomic, assign) CGRect frameRect2;

@end


#ifdef SLIDE_UP_TEXTFIELDS
const CGFloat fieldWidth = 200;
const CGFloat fieldHeight = 40;
const CGFloat fieldGap = 10;
const CGFloat fieldBase = 20;

#else
const CGFloat fieldWidth = 200;
const CGFloat fieldHeight = 40;
const CGFloat fieldGap = 10;
const CGFloat fieldBase = 360;

#endif
@implementation FNView



#pragma mark - init, dealloc, setup

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)dealloc {
    [self removeNotifications];
}

- (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setup {
    
    [self setKeyboardNotifications];
    
#ifdef BUG_FIX
    self.textField1 = [[FNTextField alloc] init];
    self.textField2 = [[FNTextField alloc] init];
#else
    self.textField1 = [[UITextField alloc] init];
    self.textField2 = [[UITextField alloc] init];
#endif
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    [self addSubview:self.textField1];
    [self addSubview:self.textField2];
    [self setupTextField:self.textField1];
    [self setupTextField:self.textField2];
    
    
#ifdef USE_AUTOLAYOUT
    self.textField1.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField2.translatesAutoresizingMaskIntoConstraints = NO;
    self.spacer1 = [[UIView alloc] init];
    self.spacer2 = [[UIView alloc] init];
    self.spacer1.translatesAutoresizingMaskIntoConstraints  = NO;
    self.spacer2.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.spacer1];
    [self addSubview:self.spacer2];
#else
    CGFloat offsetX = (self.bounds.size.width - fieldWidth) / 2.0f;
    CGFloat offsetY1 = self.bounds.size.height - fieldBase - fieldHeight;
    CGFloat offsetY2 = offsetY1 - fieldGap-fieldHeight;
    self.frameRect1 =CGRectMake(offsetX, offsetY1, fieldWidth, fieldHeight);
    self.frameRect2 = CGRectMake(offsetX, offsetY2, fieldWidth, fieldHeight);
    
    self.textField1.frame = self.frameRect1;
    self.textField2.frame = self.frameRect2;
#endif
    
}


- (void) setupTextField:(UITextField*)textField {
    textField.layer.borderColor = [UIColor redColor].CGColor;
    textField.layer.borderWidth =  2.0f;
    textField.textColor = [UIColor blackColor];
    textField.placeholder = @"placeholder";
}

#pragma mark - derived properties

- (CGFloat)keyboardHeight:(NSNotification*)notification {
    return [self keyboardRect:notification].size.height;
}
- (CGRect)keyboardRect:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey];
    return [keyboardFrameEnd CGRectValue];
}

#pragma mark - actions




#pragma mark - keyboard notifications

- (void)setKeyboardNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShowNotification:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHideNotification:) name: UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidShowNotification:) name: UIKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidHideNotification:) name: UIKeyboardDidHideNotification object:nil];
}

- (void)removeNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillHideNotification:(NSNotification *)notification  {
    self.keyboardHeight = 0;
    [self keyboardWillChange:notification.userInfo];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    self.keyboardHeight = [self keyboardHeight:notification];
    [self keyboardWillChange:notification.userInfo];
    
}

- (void)keyboardDidHideNotification:(NSNotification *)notification  {
    
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {


}

- (void)keyboardWillChange:(NSDictionary*)userInfo
{
    /*
     in the bug case (only) we also get these NSLayoutConstraint warnings triggered BEFORE we call the constraints methods here. I strongly suspect there is a connection!
     
     2015-10-09 01:36:07.961 TextFieldTest[1427:311122] Unable to simultaneously satisfy constraints.
     Probably at least one of the constraints in the following list is one you don't want. Try this: (1) look at each constraint and try to figure out which you don't expect; (2) find the code that added the unwanted constraint or constraints and fix it. (Note: If you're seeing NSAutoresizingMaskLayoutConstraints that you don't understand, refer to the documentation for the UIView property translatesAutoresizingMaskIntoConstraints)
     (
     "<NSLayoutConstraint:0x156e91050 V:|-(20)-[UIInputSetContainerView:0x156e73820]   (Names: '|':UIRemoteKeyboardWindow:0x156dafb70 )>",
     "<NSLayoutConstraint:0x156da9be0 'UIInputWindowController-top' V:|-(0)-[UIInputSetContainerView:0x156e73820]   (Names: '|':UIRemoteKeyboardWindow:0x156dafb70 )>"
     )
     
     Will attempt to recover by breaking constraint
     <NSLayoutConstraint:0x156e91050 V:|-(20)-[UIInputSetContainerView:0x156e73820]   (Names: '|':UIRemoteKeyboardWindow:0x156dafb70 )>
     
     Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.
     The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.
     
     */
#ifdef USE_AUTOLAYOUT
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
    
#else
    CGRect frame1 = self.frameRect1;
    CGRect frame2 = self.frameRect2;
    if (frame1.origin.y > self.bounds.size.height - [self keyboardHeight]) {
        frame1.origin.y -= [self keyboardHeight]*1.0;
        self.textField1.frame = frame1;
    }

    if (frame2.origin.y > self.bounds.size.height - [self keyboardHeight]) {
        frame2.origin.y -= [self keyboardHeight]*1.0;
        self.textField2.frame = frame2;
    }
 
    
#endif
}



#pragma mark - touch


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //getting rid of the keyboard if we are not in the textField
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - constraints

#ifdef USE_AUTOLAYOUT

- (void)updateConstraints {
    [super updateConstraints];
    [self removeConstraints:self.constraints];
    NSString* formatV = @"V:[textField1(==40)]-(fieldGap)-[textField2(==fieldHeight)]-(fieldBase)-|";
    NSString* formatH1 = @"H:|-[spacer1(>=0)][textField2(==fieldWidth)][spacer2(==spacer1)]-|";
    NSString* formatH2 = @"H:|-[spacer1(>=0)][textField1(==fieldWidth)][spacer2(==spacer1)]-|";
    CGFloat fieldBottom = fieldBase;
    if (fieldBottom < self.keyboardHeight) {
        fieldBottom = self.keyboardHeight + 40;
    }
    
    NSDictionary* metrics = @{
                               @"fieldGap":@(fieldGap)
                              ,@"fieldWidth":@(fieldWidth)
                              ,@"fieldHeight":@(fieldHeight)
                              ,@"fieldBase":@(fieldBottom)};
    NSDictionary* views = @{
                            @"textField1":self.textField1
                            ,@"textField2":self.textField2
                            ,@"spacer1":self.spacer1
                            ,@"spacer2":self.spacer2
                            };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatV options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatH1 options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatH2 options:0 metrics:metrics views:views]];
    
    
    
    
}

#endif
@end
