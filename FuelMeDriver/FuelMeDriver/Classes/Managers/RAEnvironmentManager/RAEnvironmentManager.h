//
//  RAEnvironmentManager.h
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAEnvironmentDefines.h"

@interface RAEnvironmentManager : NSObject

@property (nonatomic, readonly, getter=isTestMode) BOOL testMode;

//FIX: RA-5442 required NOT readonly properties here
@property (nonatomic, strong) NSString *serverUrl;

//readonly properties (defined by functions)
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) NSString *completeVersion;
@property (nonatomic, readonly) NSString *environmentString;

@property (nonatomic) RAEnvironment environment;

+ (RAEnvironmentManager*)sharedManager;

- (BOOL)isTestServer;
- (BOOL)isStageServer;
- (BOOL)isCustomServer;
- (BOOL)isProdServer;
- (BOOL)isEmptyEnvironment;
+ (NSString *)userAgentVersion;

@end

@interface RAEnvironmentManager (Customization)

-(void)setCustomServerURL:(NSString*)serverURL;

@end
