//
//  NSString+Utils.m
//  RideDriver
//
//  Created by Carlos Alcala on 8/31/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "NSString+Utils.h"

#import "QueueEvent.h"
#import "RACarCategoryDataModel+Collections.h"
#import "RASessionManager.h"

@implementation NSString (Utils)

+ (NSString*) addSuffixToNumber:(NSInteger) number {
    NSString *suffix;
    int ones = number % 10;
    int tens = (number/10) % 10;
    
    if (tens ==1) {
        suffix = @"th";
    } else if (ones ==1){
        suffix = @"st";
    } else if (ones ==2){
        suffix = @"nd";
    } else if (ones ==3){
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    
    NSString * completeAsString = [NSString stringWithFormat:@"%d%@", (int)number, suffix];
    return completeAsString;
}

- (NSString*)validPhoneWithSINFormat:(SINPhoneNumberFormat)format {
    // setup default region
    NSString* defaultRegion = [SINDeviceRegion currentCountryCode];
    NSError *parseError = nil;
    id<SINPhoneNumber> phoneNumber = [SINPhoneNumberUtil() parse:self
                                                   defaultRegion:defaultRegion
                                                           error:&parseError];
    
    if (parseError != nil) {
        return nil;
    }
    
    NSString *phoneNumberWithFormat = [SINPhoneNumberUtil() formatNumber:phoneNumber
                                                                  format:format];
    return phoneNumberWithFormat;
}

- (NSString*)matchWithPattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    NSString* match = @"";
    
    if (error) {
        return match;
    }
    
    NSArray* matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (matches.count > 0) {
        match = [self substringWithRange:[matches[0] range]];
    }
    
    return match;
}

+(NSString*)getPhotoTypeStringWithCarPhotoType:(CarPhotoType)carPhotoType{
    NSString *type = @"";
    switch (carPhotoType) {
        case FrontPhoto:
            type = @"FRONT";
            break;
        case BackPhoto:
            type = @"BACK";
            break;
        case InsidePhoto:
            type = @"INSIDE";
            break;
        case TrunkPhoto:
            type = @"TRUNK";
            break;
        default:
            break;
    }
    return type;
}

/**
 
 Welcome to the RideAustin airport zone. (ENTERING ONLY)
 
 You are vehicle X in the regular vehicle queue,
 vehicle Y in the SUV queue,
 vehicle Z in the premium queue.' For the interim messages.
 
 You are next in the regular vehicle queue (when displayPosition is 1)
 */
+ (NSString *)queueUpdateMessageWithEvent:(QueueEvent *)queueEvent fromPositions:(NSDictionary *)response {
    NSString *message = @"";
    NSString *youAre  = @"You are ";
    NSString *positionString  = @"";
    DriverEventType event = queueEvent.eventType;
    
    NSArray<RACarCategoryDataModel *> *userCarCategories = [RASessionManager shared].currentSession.userCarTypes.stringToCarCategories;
    //FIX - 4609 check for NSArray RideTypes
    if ([userCarCategories isKindOfClass:NSArray.class] &&
        [response isKindOfClass:NSDictionary.class]) {
        if (event == QueueEntering) {
            message = [message stringByAppendingString:queueEvent.welcomeMessage];
        }
        message = [message stringByAppendingString:youAre];
        
        //Show Queue positions by ascending order
        NSArray<RACarCategoryDataModel *> *sortedCategoriesByQueuePosition = [userCarCategories sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull rideTypeLeft, id  _Nonnull rideTypeRight) {
            id positionLeft = response[rideTypeLeft];
            if (![positionLeft isKindOfClass:[NSNumber class]]) {
                return NSOrderedDescending;
            }
            
            id positionRight = response[rideTypeRight];
            if (![positionRight isKindOfClass:[NSNumber class]]) {
                return NSOrderedAscending;
            }
            
            return [positionLeft compare:positionRight];
        }];
        
        for (RACarCategoryDataModel *category in sortedCategoriesByQueuePosition) {
            id position = response[category.carCategory];
            if (position) {
                NSInteger displayPosition = [position integerValue] + 1;
                
                //FIX: RA-2377 - Position with Suffix String (as suggested by Maxim)
                //setup position Suffix (to get the 'th' 'st' 'nd' 'rd' number endings)
                NSString* posSuffix = [NSString addSuffixToNumber:displayPosition];
                
                NSString* nextPos = [NSString stringWithFormat:@"%@ in the %@ vehicle queue", posSuffix, category.title];
                positionString = [positionString stringByAppendingString:nextPos];
                
                //RideType Object isEqual
                BOOL isLastItem = [category isEqual:sortedCategoriesByQueuePosition.lastObject];
                if (isLastItem) {
                    positionString = [positionString stringByAppendingString:@"."];
                } else {
                    positionString = [positionString stringByAppendingString:@",\n"];
                }
            }
        }
        
        if ([positionString isEqualToString:@""]) {
            //FIX: RA-2377 - Position String by default if there is no other position
            positionString = @"1st in queue.";
        }
        
        message = [message stringByAppendingString:positionString];
        
        return message;
    }
    return nil;
}

-(NSDate *)httpHeaderResponseDate{
    NSDateFormatter *df = [NSDateFormatter new];
    df.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    df.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    [df setDateFormat:@"eee, dd MMM yyyy HH:mm:ss z"];
    return [df dateFromString:self];
}

- (NSString *)localized {
    return NSLocalizedString(self, @"");
}

@end
