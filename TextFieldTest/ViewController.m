//
//  ViewController.m
//  TextFieldTest
//
//  Created by jonathan on 08/10/2015.
//  Copyright © 2015 foundry. All rights reserved.
//  develop@foundry.tv

#import "ViewController.h"
#import "FNView.h"
@interface ViewController ()
@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, strong) FNView* testView;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef USE_AUTOLAYOUT
    NSString* layoutSring = @"using autolayout";
#else
    NSSting* layoutString = @"using frames";
#endif
    NSString* iosString = ([self wn_system9])?@"ios9":@"ios8";
    self.title = [NSString stringWithFormat:@"%@ - %@", iosString, layoutSring];
}


- (void)viewDidAppear:(BOOL)animated {
    self.testView = [[FNView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.testView];
    [super viewDidAppear:animated];
}
- (BOOL)wn_system9
{
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    return (9 <= [[versionCompatibility objectAtIndex:0] intValue]);
}



@end
