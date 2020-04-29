//
//  DucklingView.h
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DucklingModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface DucklingView : UIView

// 倒鸭子数据
@property(nonatomic,strong)NSArray <DucklingModel *> *data;

// 时间游标,秒数
@property(nonatomic)NSTimeInterval cursor;


#pragma mark - 配置相关

// 绘制最近多少条，默认12条
@property(nonatomic)int count;

// 动画原点y轴的偏移量,默认正中间
@property(nonatomic)float originOffsety;

// 上下两行的间距，默认0
@property(nonatomic)float lineInterval;

// 字的最大宽度到视图两次的间隙,默认150
@property(nonatomic)float padding;

// 转场动画的放大缩小比例, 默认1.5倍
@property(nonatomic)float scaleFactor;

// 设置最大字号,默认50
@property(nonatomic)float maxFontSize;

@end

NS_ASSUME_NONNULL_END
