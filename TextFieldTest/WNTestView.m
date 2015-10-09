//
//  WNTestView.m
//  TextFieldTest
//
//  Created by jonathan on 08/10/2015.
//  Copyright © 2015 foundry. All rights reserved.
//  develop@foundry.tv

#import "WNTestView.h"
@interface WNTestView()
@property (nonatomic, strong) UIView* spacer1;
@property (nonatomic, strong) UIView* spacer2;
@property (nonatomic, assign) CGRect frameRect1;
@property (nonatomic, assign) CGRect frameRect2;

@end


const CGFloat fieldWidth = 200;
const CGFloat fieldHeight = 40;
const CGFloat fieldGap = 10;
const CGFloat fieldBase = 20;
@implementation WNTestView


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
 
 */
#define USE_AUTOLAYOUT

#pragma mark - init, dealloc, setup

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)setup {
    
    
    [self setKeyboardNotifications];
    
    
    self.textField1 = [[UITextField alloc] init];
    self.textField2 = [[UITextField alloc] init];
    
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
    
#ifdef USE_AUTOLAYOUT
    
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
    
#else
    CGRect frame1 = self.frameRect1;
    CGRect frame2 = self.frameRect2;
    
    frame1.origin.y -= [self keyboardHeight]*1.0;
    frame2.origin.y -= [self keyboardHeight]*1.0;
    
    self.textField1.frame = frame1;
    self.textField2.frame = frame2;
    
    
    
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
    
    NSDictionary* metrics = @{
                               @"fieldGap":@(fieldGap)
                              ,@"fieldWidth":@(fieldWidth)
                              ,@"fieldHeight":@(fieldHeight)
                              ,@"fieldBase":@(self.keyboardHeight+fieldBase)};
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
