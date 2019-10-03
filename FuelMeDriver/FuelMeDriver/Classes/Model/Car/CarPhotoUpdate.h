//
//  CarPhotoUpdate.h
//  RideDriver
//
//  Created by Abdul Rehman on 09/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RideDriverEnums.h"

@interface CarPhotoUpdate : NSObject

@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, assign) CarPhotoType type;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) UIImage *placeHolderLarge;
@property (nonatomic, readonly) NSString *topTitlePhoto;
@property (nonatomic, assign) BOOL isLoaded;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithType:(CarPhotoType)type;

@end
