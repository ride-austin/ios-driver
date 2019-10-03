//
//  VersionManager.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 7/26/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RAVerifyVersionCompletionBlock)(BOOL shouldUpgrade, BOOL isMandatory);

@interface VersionManager : NSObject

+ (void)checkNewVersionAvailableWithCompletion:(RAVerifyVersionCompletionBlock)handler;
+ (void)showAlertIfNeeded;
+ (void)resetOptionalUpgradeDate;

@end
