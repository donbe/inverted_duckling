//
//  DucklingModel.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/28.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "DucklingModel.h"

@implementation DucklingModel
+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}
@end
