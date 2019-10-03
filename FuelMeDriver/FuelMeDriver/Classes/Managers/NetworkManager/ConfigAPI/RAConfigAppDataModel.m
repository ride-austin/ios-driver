//
//  RAConfigApp.m
//  Ride
//
//  Created by Kitos on 8/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAConfigAppDataModel.h"

@interface RAConfigAppDataModel ()

@property (nonatomic) BOOL shouldUpgrade;
@property (nonatomic) BOOL mustUpgrade;

@end

@interface RAConfigAppDataModel (Private)

-(BOOL)getUpgradeStatus;

@end

@implementation RAConfigAppDataModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:
                @{
                  @"avatar":@"avatarType",
                  @"platform":@"platformType",
                  @"version":@"version",
                  @"mandatoryUpgrade":@"mandatoryUpgrade",
                  @"userAgentHeader":@"userAgentHeader",
                  @"upgradeURL":@"downloadUrl"
                  }
            ];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self) {
        self.shouldUpgrade = [self getUpgradeStatus];
        self.mustUpgrade = self.shouldUpgrade && self.isMandatory;
        DBLog(@"should upgrade: %@ - mandatory: %@",self.shouldUpgrade?@"Yes":@"No", self.isMandatory?@"Yes":@"No");
    }
    
    return self;
}

@end

#pragma mark - Private

//Taken work on Driver app to match vesion comparison: https://bitbucket.org/fuelmedevelopers/ridedriverios/commits/2ad4020238ce408caf8e395b9731e963badf5b5d
#import "NSString+Utils.h"
#import "NSString+CompareToVersion.h"

//version format pattern AnyInt.AnyInt.AnyInt
static NSString *const kVersionPattern = @"[0-9]+\\.[0-9]+\\.[0-9]+";

@implementation RAConfigAppDataModel (Private)

-(BOOL)getUpgradeStatus{
    NSString *appVersion = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"] matchWithPattern:kVersionPattern];
    NSString *serverVersion = [self.version matchWithPattern:kVersionPattern];
    DBLog(@"app version: %@ - server version: %@",appVersion, serverVersion);
    return [appVersion isOlderThanVersion:serverVersion];
}

@end
