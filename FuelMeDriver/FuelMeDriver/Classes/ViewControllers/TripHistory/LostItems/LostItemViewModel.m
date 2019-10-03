//
//  LostItemViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LostItemViewModel.h"

#import "BaseXLButtonCell.h"
#import "LIMultiLineLabelCell.h"
#import "LIOptionDataModel.h"
#import "LIRequestModel.h"
#import "NSDictionary+JSON.h"
#import "SupportTopicAPI.h"

#import <XLForm/XLForm.h>

@interface LostItemViewModel()

@property (nonatomic, readonly) NSString *actionType;

@end

@implementation LostItemViewModel

+ (instancetype)testViewModel {
    //temporary
    NSError *error = nil;
    NSDictionary *json = [NSDictionary jsonFromResourceName:@"lostitem" error:&error];
    NSAssert(error == nil, @"lostitem failed");
    LIOptionDataModel *optionModel = [MTLJSONAdapter modelOfClass:LIOptionDataModel.class fromJSONDictionary:json error:&error];
    NSAssert(error == nil, @"LIOptionDataModel failed");
    return [[self alloc] initWithDataModel:optionModel rideId:@(123)];
}

- (instancetype)initWithDataModel:(LIOptionDataModel *)optionModel rideId:(NSNumber *)rideId {
    if (self = [super init]) {
        _rideId         = rideId;
        _fields         = [self viewModelsFromFields:optionModel.fields];
        _title          = optionModel.title;
        _headerText     = optionModel.headerText;
        _body           = [optionModel.body stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        _actionTitle    = optionModel.actionTitle;
        _actionType     = optionModel.actionType;
        _actionRowType  = XLFormRowDescriptorTypeBaseXLButtonCell;
        _rowType        = XLFormRowDescriptorTypeLIMultiLineLabelCell;
        
    }
    return self;
}

- (NSArray<LIFieldViewModel *> *)viewModelsFromFields:(NSArray<LIFieldDataModel *> *)fields {
    NSMutableArray *vms = [NSMutableArray new];
    for (LIFieldDataModel *field in fields) {
        LIFieldViewModel *vm = [LIFieldViewModel viewModelWithDataModel:field];
        [vms addObject:vm];
    }
    return vms.copy;
}

- (ActionButtonType)actionButtonType {
    if (self.fields.count > 0) {
        if ([self.actionType isEqualToString:@"lostandfound/contact"]) {
            return ActionButtonCallDriver;
        } else if ([self.actionType isEqualToString:@"lostandfound/lost"]) {
            return ActionButtonReportItemLost;
        } else if ([self.actionType isEqualToString:@"lostandfound/found"]) {
            return ActionButtonReportItemFound;
        } else if ([self.actionType isEqualToString:@""] == NO) {
            return ActionButtonReportDefault;
        }
    }
    return ActionButtonNone;
}

#pragma mark - Request
- (void)submitRequestWithFormValues:(NSDictionary *)formValues withCompletion:(void(^)(NSString *successMessage, NSError *error))completion {
    LIRequestModel *item = [LIRequestModel itemFromFormValues:formValues rideId:self.rideId andFields:self.fields];
    switch (self.actionButtonType) {
        case ActionButtonReportItemLost:
            [SupportTopicAPI postLostAndFoundLostParameters:item.parameters
                                             withCompletion:completion];
            break;
        case ActionButtonReportItemFound:
            [SupportTopicAPI postLostAndFoundFoundParameters:item.parameters
                                                   andImages:item.images
                                              withCompletion:completion];
            break;
        case ActionButtonCallDriver:
            [SupportTopicAPI postLostAndFoundContactParameters:item.parameters withCompletion:completion];
            break;
        case ActionButtonNone:
            break;
            
        default:
            break;
    }
}

@end
