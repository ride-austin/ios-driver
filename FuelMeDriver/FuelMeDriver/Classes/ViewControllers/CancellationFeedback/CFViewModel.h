//
//  CFViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/24/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFReasonDataModel.h"
@class RARideDataModel;
@interface CFViewModel : NSObject

@property (nonatomic, readonly, nonnull) NSArray<CFReasonDataModel *>*items;
@property (nonatomic, readonly, nonnull) NSString *title;
@property (nonatomic, readonly, nonnull) NSString *subtitle;
- (void)setRide:(RARideDataModel * _Nonnull)ride;
- (void)getReasonsWithCompletion:(void(^_Nonnull)(NSError *_Nullable error))completion;
- (void)submitCancellationReason:(NSString *_Nonnull)reasonCode comment:(NSString *_Nullable)comment withCompletion:(void(^_Nonnull)(NSError * _Nullable error))completion;

@end
