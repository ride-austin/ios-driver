//
//  UIImage+Utils.m
//  RideDriver
//
//  Created by Carlos Alcala on 8/9/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "UIImage+Utils.h"

@interface UIImage (Private)

+ (void)beginImageContextWithSize:(CGSize)size;
+ (void)endImageContext;

@end

@implementation UIImage (Utils)

+ (UIImage *)resizeImage:(UIImage *)baseImage size:(CGSize)size withInterpolationQuality:(CGInterpolationQuality)quality {
    if (CGSizeEqualToSize(baseImage.size, size)) {
        return baseImage;
    }
    if (size.width > baseImage.size.width || size.height > baseImage.size.height) {
        return baseImage;
    }
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [baseImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage *)scaledImageTo:(CGFloat)scale{
    return [UIImage imageWithCGImage:self.CGImage scale:4.0 orientation:UIImageOrientationUp];
}

- (UIImage*)scaledToSize:(CGSize)newSize {
    [UIImage beginImageContextWithSize:newSize];
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [UIImage endImageContext];
    return newImage;
}

- (UIImage*)scaledToMaxArea:(CGFloat)absoluteMaxArea {
    return [self scaledToSize:self.size andMaxArea:absoluteMaxArea];
}

- (UIImage*)scaledToSize:(CGSize)newSize andMaxArea:(CGFloat)absoluteMaxArea {
    CGFloat maxArea = 0.9 * absoluteMaxArea;
    CGFloat area = newSize.width * newSize.height;
    if (area < maxArea) {
        return CGSizeEqualToSize(newSize, self.size) ? self : [self scaledToSize:newSize];
    } else {
        CGFloat factor = sqrt(maxArea/area);
        CGFloat maxDim = MAX(newSize.width,newSize.height);
        CGFloat minDim = MIN(newSize.width,newSize.height);
        BOOL isPortrait = maxDim == newSize.height;
        
        CGFloat smallerMaxDim = factor * maxDim;
        CGFloat smallerMinDim = factor * minDim;
        
        CGSize smallerSize = isPortrait ?
        CGSizeMake(smallerMinDim, smallerMaxDim):
        CGSizeMake(smallerMaxDim, smallerMinDim);
        //DBLog(@"image resized from (%lfX%lf)%lf to (%lfX%lf)%lf", newSize.width, newSize.height, area,smallerSize.width, smallerSize.height, smallerSize.width * smallerSize.height);
        return [self scaledToSize:smallerSize];
    }
}
-(UIImage *)combineWithImage:(UIImage *)image2 {
    if (image2) {
        CGFloat maxWidth  = MAX(self.size.width , image2.size.width);
        CGFloat minWidth  = MIN(self.size.width , image2.size.width);
        CGFloat maxHeight = MAX(self.size.height, image2.size.height);
      //CGFloat minHeight = MIN(self.size.height, image2.size.height);
        CGSize size = CGSizeMake(maxWidth + minWidth, maxHeight);
        
        UIGraphicsBeginImageContext(size);
        
        [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
        [image2 drawInRect:CGRectMake(self.size.width,0,image2.size.width, image2.size.height)];
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        //set finalImage to IBOulet UIImageView
        return finalImage;
    } else {
        return self;
    }
}
@end
#pragma mark - Private


@implementation UIImage (Private)

+ (void)beginImageContextWithSize:(CGSize)size {
    /*if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
     if ([[UIScreen mainScreen] scale] == 2.0) {
     UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
     } else {
     UIGraphicsBeginImageContext(size);
     }
     } else {*/
    UIGraphicsBeginImageContext(size);
    //}
}

+ (void)endImageContext {
    UIGraphicsEndImageContext();
}

@end
