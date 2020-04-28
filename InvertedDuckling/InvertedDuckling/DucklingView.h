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


// 动画原点y轴的偏移量,默认正中间
@property(nonatomic)float originOffsety;

// 上下两行的间距
@property(nonatomic)float lineInterval;

// 转场动画的放大缩小比例, 默认1.5倍
@property(nonatomic)float scaleFactor;

// 倒鸭子数据
@property(nonatomic,strong)NSArray <DucklingModel *> *data;

// 动画的中间过程值
@property(nonatomic)float percent;

@end

NS_ASSUME_NONNULL_END
