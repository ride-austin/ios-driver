//
//  RADateManager.m
//  RideDriver
//
//  Created by Roberto Abreu on 27/1/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "RADateManager.h"

#import <TrueTime/TrueTime-Swift.h>

@interface RADateManager ()

@property (nonatomic,strong) TrueTimeClient *client;

@end

@implementation RADateManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RADateManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RADateManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.client = [TrueTimeClient sharedInstance];
        [self.client startWithHostURLs:@[[NSURL URLWithString:@"time.apple.com"]]];
    }
    return self;
}

- (NSDate *)currentDate {
    return [[self.client referenceTime] now] ?: [NSDate date];
}

- (void)fetchCurrentDate:(TimeDateBlock)completion {
    [self.client fetchFirstIfNeededWithSuccess:^(NTPReferenceTime * _Nonnull referenceTime) {
        if (completion) {
            completion(referenceTime.now,nil);
        }
    } failure:^(NSError * _Nonnull error) {
        if (completion) {
            completion(nil,error);
        }
    }];
}

@end
