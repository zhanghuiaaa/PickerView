//
//  ViewController.m
//  PickerView
//
//  Created by 骊蘅 on 2018/3/13.
//  Copyright © 2018年 ZYH. All rights reserved.
//

#import "ViewController.h"
#import "PickerView.h"
@interface ViewController ()
@property(strong, nonatomic) PickerView *pickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    UIButton * add = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    add.backgroundColor = [UIColor redColor];
    [add addTarget:self action:@selector(clicjk) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:add];
    
    
    
    
}

- (void)clicjk{
    
    PickerView *pickerView = [[PickerView alloc] initWithFrame:self.view.bounds];
    
    self.pickerView = pickerView;
    [self.view addSubview:pickerView];
    
}

@end
