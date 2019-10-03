//
//  UIImage+Ride.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/10/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "UIImage+Ride.h"

@implementation UIImage (Ride)

+ (void)beginImageContextWithSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)endImageContext {
    UIGraphicsEndImageContext();
}


+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    [self beginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToMaxArea:(CGFloat)absoluteMaxArea {
    return [self imageWithImage:image scaledToSize:image.size andMaxArea:absoluteMaxArea];
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize andMaxArea:(CGFloat)absoluteMaxArea {
    CGFloat maxArea = 0.9 * absoluteMaxArea;
    CGFloat area = newSize.width * newSize.height;
    if (area < maxArea) {
        return CGSizeEqualToSize(newSize, image.size) ? image : [self imageWithImage:image scaledToSize:newSize];
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
        DBLog(@"image resized from (%lfX%lf)%lf to (%lfX%lf)%lf", newSize.width, newSize.height, area,smallerSize.width, smallerSize.height, smallerSize.width * smallerSize.height);
        return [self imageWithImage:image scaledToSize:smallerSize];
    }
}

- (BOOL)imageValidSizeForMinArea:(CGFloat)minArea {
    
    CGFloat imageArea = self.size.width * self.size.height;
    
    if (imageArea < minArea) {
        return NO;
    } else {
        return YES;
    }
}
- (NSData *)compressToMaxSize:(CGFloat)maxSize {
    //Compress the image
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    DBLog(@"Uncompressed : %lu",(unsigned long)imageData.length);
    while ([imageData length] > maxSize && compression > maxCompression)
    {
        compression -= 0.05;
        imageData = UIImageJPEGRepresentation(self, compression);
    }
    DBLog(@"Compress : %lu",(unsigned long)imageData.length);
    return imageData;
}


@end
