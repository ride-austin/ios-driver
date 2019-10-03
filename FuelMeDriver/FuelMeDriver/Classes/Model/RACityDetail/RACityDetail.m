//
//  RACityDetail.m
//  Ride
//
//  Created by Roberto Abreu on 20/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RACityDetail.h"

@implementation RACityDetail

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
              @"cityDescription"    :@"description",
              @"isEnabled"          :@"enabled",
              @"logoURLwhite"       :@"logoWhiteUrl",
              @"requirements"       :@"requirements",
              @"minCarYear"         :@"minCarYear",
              @"addCarSuccessMessage":@"newCarSuccessMessage",
              @"inspectionSticker"  :@"inspection_sticker",
              @"tnc"                :@"tnc_card"
            };
}

+ (NSValueTransformer *)logoURLwhiteJSONTransformer {
    return [MTLJSONAdapter NSURLJSONTransformer];
}

+ (NSValueTransformer *)inspectionStickerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[RAInspectionStickerDetail class]];
}

+ (NSValueTransformer *)tncJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[TNCScreenDetail class]];
}

- (NSArray<NSURL *> *)urls {
    NSMutableArray *mArray = [NSMutableArray new];
    if (self.logoURLwhite) {
        [mArray addObject:self.logoURLwhite];
    }
    return mArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.addCarSuccessMessage = @"We will review your account and will get back with you soon!";
    }
    return self;
}

@end

/* SAMPLE DEC 13
{
    description = "Thank you for choosing to drive with R|H in selected city. To qualify, drivers are required to be 21 years of age and have vehicles that are:";
    enabled = 1;
    "inspection_sticker" =     {
        enabled = 1;
        header = "Auto Inspection Sticker";
        "sticker_required_year" = 2008;
        text1 = "Please make sure that we can easiliy read all the details.";
        title1 = "Take a photo of your Inspection Sticker";
    };
    logoWhiteUrl = "https://media.rideaustin.com/images/logoRideHouston@3x.png";
    minCarYear = 2006;
    requirements =     (
                        "2006 or Newer",
                        "4 Door",
                        "Not salvaged or Re-built Vehicles"
                        );
    "tnc_card" =     {
        action1 = "If you have this, upload a picture";
        backPhoto = 0;
        enabled = 1;
        header = "Vehicle TNC Card Upload";
        text1 = "You will need a TNC Card from the City Transportation Office listing R|H or R|A as one of your preferred TNCs. If you have this, upload a picture here:";
        text2 = "View instructions <a href=\"https://media.rideaustin.com/download/Houston_TNC_Application_Form_2016.pdf\">here</a> on how to obtain one. Download TNC Driver Registration forms <a href=\"https://media.rideaustin.com/download/Houston_TNC_Application_Form_2016.pdf\">here</a>.";
        title1 = "TNC Driver Card";
        title2 = "Don't have ONE ?";
    };
}
*/
