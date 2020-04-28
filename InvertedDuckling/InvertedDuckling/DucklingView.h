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

@property(nonatomic,strong)NSArray <DucklingModel *> *data;

@property(nonatomic)float clock;

@end

NS_ASSUME_NONNULL_END
