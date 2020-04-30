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

@property(nonatomic)NSTimeInterval cursor; //执行动画总时长
@property(nonatomic,strong)UISlider *slider; //滑竿

@end


@implementation ViewController


//可用自定义字体
//ZhenyanGB-Regular
//xiaowei
//PangMenZhengDao
//HappyZcool-2016
//SourceHanSansCN-Bold
//SourceHanSerif-Heavy

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.

    self.iDuckling = [[DucklingView alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.width)];
    self.iDuckling.backgroundColor = [UIColor colorFromHexAlphaString:@"f1f1f1"];
    [self.view addSubview:self.iDuckling];
    
    self.iDuckling.data = [self testData];
    self.iDuckling.cursor = 0;
    
    [self addButtonWith:@"开始" frame:CGRectMake(20, 630, 100, 50) action:@selector(startAction)];
    [self addButtonWith:@"停止" frame:CGRectMake(140, 630, 100, 50) action:@selector(stopAction)];
//    [self addButtonWith:@"倒播" frame:CGRectMake(260, 530, 100, 50) action:@selector(triggerButtonAction)];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 550, self.view.frame.size.width-40, 50)];
    [self.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    
}

-(void)startAction{
    __weak ViewController *weakself = self;
    
    [self.timer invalidate];
    self.cursor = 0;;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        weakself.cursor += 0.01;
        weakself.iDuckling.cursor = weakself.cursor;
    }];
}

-(void)stopAction{
    [self.timer invalidate];
}

-(void)sliderValueChange:(UISlider *)slider{
    float value = slider.value * 6;
    self.iDuckling.cursor = value;
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


-(NSArray <DucklingModel *>*)testData{
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"json"];
    NSData *partyData = [[NSData alloc] initWithContentsOfFile:fileName];
    
    NSError *error;
    NSArray *data = [DucklingModel arrayOfModelsFromData:partyData error:&error];
    assert(error == nil);
    
    return data;
}

@end
