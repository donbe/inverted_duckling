//
//  DucklingView.h
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DucklingView : UIView

@property(nonatomic)float clock;

+(CGPoint)point:(CGPoint)point angle:(CGFloat)angle;


@end

NS_ASSUME_NONNULL_END
