//
//  LostItemViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LIFieldViewModel.h"

typedef NS_ENUM(NSUInteger, ActionButtonType) {
    ActionButtonNone            = 0,
    ActionButtonCallDriver      = 1,
    ActionButtonReportItemFound = 2,
    ActionButtonReportItemLost  = 3,
    ActionButtonReportDefault   = 4
};

@class XLFormDescriptor;
@class LIOptionDataModel;

@interface LostItemViewModel : NSObject

//from tripHistory
@property (nonatomic, readonly) NSNumber *rideId;
//from optionModel
@property (nonatomic, readonly) NSArray<LIFieldViewModel *> *fields;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *headerText;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *actionTitle;
@property (nonatomic, readonly) NSString *actionRowType;
@property (nonatomic, readonly) NSString *rowType;

+ (instancetype)testViewModel;
- (instancetype)initWithDataModel:(LIOptionDataModel *)optionModel rideId:(NSNumber *)rideId;
- (ActionButtonType)actionButtonType;

#pragma mark - Request
- (void)submitRequestWithFormValues:(NSDictionary *)formValues withCompletion:(void(^)(NSString *successMessage, NSError *error))completion;

@end
