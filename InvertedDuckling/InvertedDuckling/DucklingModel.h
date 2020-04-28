//
//  DucklingModel.h
//  InvertedDuckling
//
//  Created by donbe on 2020/4/28.
//  Copyright © 2020 donbe. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DucklingModel : JSONModel

@property(nonatomic) int startTime; //开始时间的毫秒数
@property(nonatomic) int duration; //持续时间的毫秒数
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) NSString *color; //十六进制演示色 例如：ffffff
@property(nonatomic) int transitionAnimation; //过场动画, 0无动画，1左旋，2右旋，3放大，4缩小

@end


NS_ASSUME_NONNULL_END
