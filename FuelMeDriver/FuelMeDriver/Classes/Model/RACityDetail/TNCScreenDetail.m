//
//  TNCScreenDetail.m
//  Ride
//
//  Created by Theodore Gonzalez on 12/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "TNCScreenDetail.h"

@implementation TNCScreenDetail

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"actionText1"    : @"action1",
              @"needsBackPhoto" : @"backPhoto",
              @"isEnabled"      : @"enabled",
              @"headerText"     : @"header",
              
              @"text1"          : @"text1",
              @"text2"          : @"text2",
              @"title1"         : @"title1",
              @"title2"         : @"title2",
              @"text1Back"      : @"text1_back",
              @"title1Back"     : @"title1_back"
            };
}

@end

/*
SAMPLE RESPONSE

{
    action1 = "If you have this, upload a picture";
    enabled = 1;
    backPhoto = true;
    header = "Vehicle TNC Card Upload";
    text1 = "You will need a TNC Card from the City Transportation Office listing R|H or R|A as one of your preferred TNCs. If you have this, upload a picture here:";
    text2 = "View instructions <a href=\"https://media.rideaustin.com/download/Houston_TNC_Application_Form_2016.pdf\">here</a> on how to obtain one. Download TNC Driver Registration forms <a href=\"https://media.rideaustin.com/download/Houston_TNC_Application_Form_2016.pdf\">here</a>.";
    title1 = "TNC Driver Card";
    title2 = "Don't have one?";
}
*/
