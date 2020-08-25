//
//  UIColor+Utils.h
//  MusicDemo
//
//  Created by YaphetS on 2020/8/13.
//  Copyright © 2020 sapphire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Utils)
/**
 *  RGB值转换为UIColor对象
 *
 *  @param inColorString RGB值，如“＃808080”这里只需要传入“808080”
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString;

+ (UIColor *)colorFromHexRGB:(NSString *)inColorString alpha:(CGFloat)alpha;

+ (UIColor *)colorFromHexRGB:(NSString *)inColorString andOpacity:(float) alpha;

+ (UIColor *)getColorWithRGB:(uint32_t)rgbValue;

+ (UIColor *)getColorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END

