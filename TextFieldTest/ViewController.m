//
//  ViewController.m
//  TextFieldTest
//
//  Created by jonathan on 08/10/2015.
//  Copyright © 2015 foundry. All rights reserved.
//

#import "ViewController.h"
#import "WNTestView.h"
@interface ViewController ()
@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, strong) WNTestView* testView;
@end

@implementation ViewController



- (void)viewDidAppear:(BOOL)animated {
    self.testView = [[WNTestView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.testView];
    [super viewDidAppear:animated];
}




@end
