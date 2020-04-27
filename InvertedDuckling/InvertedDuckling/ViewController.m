//
//  ViewController.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/23.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "ViewController.h"
#import "DucklingView.h"

@interface ViewController ()

@property(nonatomic,strong)DucklingView *iDuckling;
@property(nonatomic,weak)NSTimer *timer;

@property(nonatomic)NSTimeInterval duration; //执行动画总时长
@property(nonatomic,strong)UISlider *slider; //滑竿

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.duration = 100.0f;
    
    
    self.iDuckling = [[DucklingView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.width)];
    self.iDuckling.backgroundColor = [UIColor colorFromHexAlphaString:@"f1f1f1"];
    [self.view addSubview:self.iDuckling];
    
    
//    [self addButtonWith:@"开始" frame:CGRectMake(20, 530, 100, 50) action:@selector(triggerButtonAction)];
//    [self addButtonWith:@"停止" frame:CGRectMake(140, 530, 100, 50) action:@selector(triggerButtonAction)];
//    [self addButtonWith:@"倒播" frame:CGRectMake(260, 530, 100, 50) action:@selector(triggerButtonAction)];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 550, self.view.frame.size.width-40, 50)];
    [self.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    
    
    
}

-(void)triggerButtonAction{
    
}

-(void)sliderValueChange:(UISlider *)slider{
    self.iDuckling.clock = slider.value;
    [self.iDuckling setNeedsDisplay];
    
}

#pragma mark -
- (void)addButtonWith:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *record = [[UIButton alloc] initWithFrame:frame];
    record.layer.borderColor = [UIColor blackColor].CGColor;
    record.layer.borderWidth = 0.5;
    [record setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [record setTitle:title forState:UIControlStateNormal];
    [record addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [record setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.view addSubview:record];
}


@end
