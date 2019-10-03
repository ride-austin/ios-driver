//
//  NSString+Ride.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 10/8/12.
//  Copyright (c) 2012 FuelMe, Inc. All rights reserved.
//

#import "NSString+Ride.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Ride)

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    //Fixed warning
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (BOOL)isEmpty:(NSString*)value {
    if (value) {
        if ([value trim].length > 0) {
            return NO;
        }
    }
    return YES;
}

+ (NSString *)stringWithPhotoType:(CarPhotoType)type{
    switch (type) {
        case FrontPhoto:
            return @"FRONT";
        case BackPhoto:
            return @"BACK";
        case InsidePhoto:
            return @"INSIDE";
        case TrunkPhoto:
            return @"TRUNK";
            
        default:
            break;
    }
    return nil;
}

+ (NSString *)driverStateToString:(DriverState)state{
    switch(state) {
        case InvalidDriverState:         return @"InvalidDriverState";
        case OfflineDriverState:         return @"OfflineDriverState";
        case AvailableDriverState:       return @"AvailableDriverState";
        case GoingToPickUpDriverState:   return @"GoingToPickUpDriverState";
        case ArrivingToPickUpDriverState:return @"ArrivingToPickUpDriverState";
        case OnTripDriverState:          return @"OnTripDriverState";
        case AcceptingRequest:           return @"AcceptingRequest";
    }
}

+ (NSString *)stringFromDriverEventType:(DriverEventType)eventType{
    switch(eventType) {
        case InvalidEventType:           return @"InvalidEventType";
        case HandShake:                  return @"HandShake";
        case RideRequested:              return @"RideRequested";
        case RiderLocationUpdated:       return @"RiderLocationUpdated";
        case RiderCancelledRide:         return @"RiderCancelledRide";
        case DriverAssignedToRide:       return @"DriverAssignedToRide";
        case DriverCancelledRide:        return @"DriverCancelledRide";
        case DriverReachedRider:         return @"DriverReachedRider";
        case RideActive:                 return @"RideActive";
        case NoAvailableDriverForRide:   return @"NoAvailableDriverForRide";
        case RideCompleted:              return @"RideCompleted";
        case AdminCancelledRide:         return @"AdminCancelledRide";
        case RideDestinationUpdated:     return @"RideDestinationUpdated";
        case DriverAvailable:            return @"DriverAvailable";
        case DriverRiding:               return @"DriverRiding";
        case DriverInactive:             return @"DriverInactive";
        case CustomMessage:              return @"CustomMessage";
        case QueueEntering:              return @"QueueEntering";
        case QueueUpdate:                return @"QueueUpdate";
        case QueueLeavingArea:           return @"QueueLeavingArea";
        case QueueLeavingInactive:       return @"QueueLeavingInactive";
        case QueueLeavingInARide:        return @"QueueLeavingInARide";
        case QueueLeavingPenalty:        return @"QueueLeavingPenalty";
        case SurgeAreaChanged:           return @"SurgeAreaChanged";
        case CarCategoryChanged:         return @"CarCategoryChanged";
        case DriverTypeUpdate:           return @"DriverTypeUpdate";
        case RatingUpdated:              return @"RatingUpdated";
        case RiderCommentUpdated:        return @"RiderCommentUpdated";
        case RideUpgradeAccepted:        return @"RideUpgradeAccepted";
        case RideUpgradeRejected:        return @"RideUpgradeRejected";
        case RideStackedReassigned:      return @"RideStackedReassigned";
    }
}

@end
