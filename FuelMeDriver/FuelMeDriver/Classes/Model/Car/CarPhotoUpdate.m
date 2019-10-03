//
//  CarPhotoUpdate.m
//  RideDriver
//
//  Created by Abdul Rehman on 09/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "CarPhotoUpdate.h"

@implementation CarPhotoUpdate

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        if (![dictionary isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        self.photoID = [dictionary valueForKey:@"id"];
        self.UUID = [dictionary valueForKey:@"uuid"];
        self.imgUrl = [dictionary valueForKey:@"photoUrl"];
        self.type = [self getPhotoTypeFromCarPhotoString:[dictionary valueForKey:@"carPhotoType"]];
        [self fillPlaceholders];
    }
    return self;
}

- (instancetype)initWithType:(CarPhotoType)type {
    if (self = [super init]) {
        self.type = type;
        [self fillPlaceholders];
    }
    return  self;
}

#pragma mark - Utility methods
- (void)fillPlaceholders {
    switch (self.type) {
        case FrontPhoto:
            self.placeHolder = [UIImage imageNamed:@"iconCarFront"];
            self.placeHolderLarge = [UIImage imageNamed:@"iconCarFrontLarge"];
            break;
        case BackPhoto:
            self.placeHolder = [UIImage imageNamed:@"iconCarBack"];
            self.placeHolderLarge = [UIImage imageNamed:@"iconCarBackLarge"];
            break;
        case InsidePhoto:
            self.placeHolder = [UIImage imageNamed:@"iconSeats"];
            self.placeHolderLarge = [UIImage imageNamed:@"iconSeatsLarge"];
            break;
        case TrunkPhoto:
            self.placeHolder = [UIImage imageNamed:@"iconCarTrunk"];
            self.placeHolderLarge = [UIImage imageNamed:@"iconCarTrunkLarge"];
            break;
        default:
            break;
    }
}

- (CarPhotoType)getPhotoTypeFromCarPhotoString:(NSString *)photoString {
    CarPhotoType type = FrontPhoto;
    if ([photoString isEqualToString:@"FRONT"]) {
        type = FrontPhoto;
    }else if ([photoString isEqualToString:@"BACK"]){
        type = BackPhoto;
    }else if ([photoString isEqualToString:@"INSIDE"]){
        type = InsidePhoto;
    }else if ([photoString isEqualToString:@"TRUNK"]){
        type = TrunkPhoto;
    }
    return type;
}

- (NSString *)topTitlePhoto {
    switch (self.type) {
        case FrontPhoto:
            return @"Front Left";
            break;
        case BackPhoto:
            return @"Back Right";
            break;
        case InsidePhoto:
            return @"Back Seat";
            break;
        case TrunkPhoto:
            return @"Trunk";
            break;
        default:
            return @"";
    }
}

@end
