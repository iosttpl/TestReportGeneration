//
//  ViewController.m
//  TestReportGeneration
//
//  Created by Subramanian on 2/9/15.
//  Copyright (c) 2015 Tarento Technologies Pvt Ltd. All rights reserved.
//

#import "ViewController.h"
#import "TTPLTestReportManager.h"

@interface ViewController ()

- (IBAction)openMailComposer;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)openMailComposer {
  [[TTPLTestReportManager sharedInstance] openMailWithReport];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
