//
//  DucklingModel.h
//  InvertedDuckling
//
//  Created by donbe on 2020/4/28.
//  Copyright © 2020 donbe. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

// 转场动画枚举
typedef NS_ENUM(NSUInteger, DMTransitionType) {
    DMTransitionTypeDefault,     // 无动画
    DMTransitionTypeRotateLeft,  // 左旋
    DMTransitionTypeRotateRight, // 右旋
    DMTransitionTypeZoomIn,      // 放大
    DMTransitionTypeZoomOut      // 缩小
};

@interface DucklingModel : JSONModel

@property(nonatomic,strong) NSString *text;
@property(nonatomic) int startTime;                     //开始时间的毫秒数
@property(nonatomic) int duration;                      //持续时间的毫秒数
@property(nonatomic,strong) NSString <Optional>*font;            //字体
@property(nonatomic,strong) NSString *color;            //十六进制演示色 例如：ffffff
@property(nonatomic) DMTransitionType transitionType;   //过场动画, 0无动画，1左旋，2右旋，3放大，4缩小

@end


NS_ASSUME_NONNULL_END
