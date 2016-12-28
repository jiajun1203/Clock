//
//  ViewController.m
//  TestClock
//
//  Created by Mr.陈 on 2016/12/28.
//  Copyright © 2016年 Mr.陈. All rights reserved.
//

#import "ViewController.h"
#import "ClockView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ClockView *clockV = [[ClockView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2.0-150, self.view.frame.size.height/2.0-150, 300, 300)];
    [self.view addSubview:clockV];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
