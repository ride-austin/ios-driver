//
//  RACarCategoryDataModel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RACarCategoryConfigurationModel.h"

@interface RACarCategoryDataModel : RABaseDataModel
//unused
//@property (nonatomic, readonly) BOOL active;

@property (nonatomic, strong) NSNumber * baseFare;
@property (nonatomic, strong) NSNumber * minimumFare;
@property (nonatomic, strong) NSNumber * bookingFee; //string from server
@property (nonatomic, strong) NSNumber * cancellationFee; //string from server
@property (nonatomic, strong) NSNumber * ratePerMile; //string from server
@property (nonatomic, strong) NSNumber * ratePerMinute; //string from server
@property (nonatomic, strong) NSNumber * maxPersons;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * carCategory;
@property (nonatomic, strong) NSString * catDescription;
@property (nonatomic, strong) NSURL    * iconURL;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSNumber * raFeeFactor;
@property (nonatomic, readonly) NSNumber *tncFeeRate;
@property (nonatomic, readonly) NSString *processingFee;
@property (nonatomic, readonly) NSNumber *processingFeeRate;
@property (nonatomic, readonly) NSString *processingFeeText;
@property (nonatomic, readonly) RACarCategoryConfigurationModel *configuration;
//
// generated from configuration
//
- (BOOL)shouldShowAreaQueue;
//
//
//
- (NSString *)iconName;
- (UIImage *)icon;
@end

/*  May 30, Server 2.7
{
    active = 1;
    baseFare = "3.00";
    bookingFee = "2.00";
    cancellationFee = "6.00";
    carCategory = PREMIUM;
    cityId = 1;
    configuration = "{\"disableTipping\":true}";
    description = "Premium Car";
    iconUrl = "https://media.rideaustin.com/icon/premium.png";
    maxPersons = 4;
    minimumFare = "10.00";
    order = 3;
    processingFee = "1.00";
    processingFeeRate = 1;
    processingFeeText = "$1.00 Processing fee";
    raFeeFactor = "0.2";
    ratePerMile = "2.75";
    ratePerMinute = "0.40";
    title = PREMIUM;
    tncFeeRate = 1;
}
*/
