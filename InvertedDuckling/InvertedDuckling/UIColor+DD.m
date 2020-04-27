//
//  UIColor+DD.m
//  InvertedDuckling
//
//  Created by donbe on 2020/4/26.
//  Copyright © 2020 donbe. All rights reserved.
//

#import "UIColor+DD.h"
#define COLOR_WITH_HEX_A(hexValue, a) ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:(a)])


@implementation UIColor (DD)
#pragma mark -
+ (UIColor *)colorFromHexAlphaString:(NSString *)hexString {
    
    if (hexString.length != 8) {
        if (hexString.length == 6) {
            hexString = [NSString stringWithFormat:@"ff%@", hexString];
        }else {
            return [UIColor blackColor];
        }
    }
    
    hexString = [hexString uppercaseString];
    
    NSString *alphaStr = [hexString substringToIndex:2];
    NSString *colorStr = [hexString substringFromIndex:2];
    
    NSInteger alphaValue = [self valueFromHexString:alphaStr];
    NSInteger colorValue = [self valueFromHexString:colorStr];
    
    return COLOR_WITH_HEX_A(colorValue, alphaValue);
}

+ (NSInteger)valueFromHexString:(NSString *)string {
    
    const char *hexChar = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}
@end
