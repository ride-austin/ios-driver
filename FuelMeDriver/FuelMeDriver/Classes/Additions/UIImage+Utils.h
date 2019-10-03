//
//  UIImage+Utils.h
//  RideDriver
//
//  Created by Carlos Alcala on 8/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage *)resizeImage:(UIImage *)baseImage size:(CGSize)size withInterpolationQuality:(CGInterpolationQuality)quality;

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage*)scaledImageTo:(CGFloat)scale;
- (UIImage*)scaledToSize:(CGSize)newSize;
- (UIImage*)scaledToMaxArea:(CGFloat)absoluteMaxArea;
- (UIImage*)scaledToSize:(CGSize)newSize andMaxArea:(CGFloat)absoluteMaxArea;
- (UIImage*)combineWithImage:(UIImage *)image;
@end
