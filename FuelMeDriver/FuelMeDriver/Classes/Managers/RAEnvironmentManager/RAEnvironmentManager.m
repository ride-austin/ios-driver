//
//  RAEnvironmentManager.m
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAEnvironmentManager.h"

static NSString * const kEnvironmentKey      = @"kEnvironmentKey";
static NSString * const kCustomServerURLKey  = @"kCustomServerURLKey";

static NSString * const kRAProductionServer  = @"https://api.rideaustin.com/rest"; //--> Always HTTPS for PROD
static NSString * const kRAQAServer          = @"http://api-rc.rideaustin.com/rest";
static NSString * const kRAStageServer       = @"https://api-stage.rideaustin.com/rest";
static NSString * const kRADevServer         = @"http://api-dev.rideaustin.com/rest";
static NSString * const kRAFeatureServer     = @"http://api-feature.rideaustin.com/rest";

@implementation RAEnvironmentManager

+ (RAEnvironmentManager*)sharedManager {
    static dispatch_once_t onceToken;
    static RAEnvironmentManager *enviromentManager;
    dispatch_once(&onceToken, ^{
        enviromentManager = [[RAEnvironmentManager alloc] init];
    });
    return enviromentManager;
}

- (instancetype)init {
    if (self = [super init]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnvironmentKey]) {
            self.environment = (RAEnvironment)[[NSUserDefaults standardUserDefaults] integerForKey:kEnvironmentKey];
        } else {
            self.environment = RAEmptyEnvironment;
        }
    }
    return self;
}

-(BOOL)isTestMode{
    return ![self isProdServer] || ([self isCustomServer] && ![self.serverUrl isEqualToString:kRAProductionServer]);
}

-(void)setEnvironment:(RAEnvironment)environment{
    _environment = environment;
    
    switch (self.environment) {
        case RAStageEnvironment:
            self.serverUrl = kRAStageServer;
            
            break;
        case RAFeatureEnvironment:
            self.serverUrl = kRAFeatureServer;
            
            break;
        case RADevEnvironment:
            self.serverUrl = kRADevServer;

            break;
        case RAQAEnvironment:
            self.serverUrl = kRAQAServer;
            
            break;
        case RAProdEnvironment:
            self.serverUrl = kRAProductionServer;
            
            break;
        case RACustomEnvironment:{
            NSString *sURL = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomServerURLKey];
            self.serverUrl = sURL ? sURL : kRAStageServer;
        }
            break;
            
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.environment forKey:kEnvironmentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)version {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    
    if ([self isTestMode]) {
        NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
        version = [version stringByAppendingFormat:@" (%@) - %@", build, [self environmentString]];
    }
    
    return version;
}

+ (NSString *)userAgentVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    return [version stringByAppendingFormat:@" (%@)", build];
}

-(NSString *)completeVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    return [version stringByAppendingFormat:@" (%@)", build];
}

-(NSString *)environmentString{
    NSString *env = @"Unknown";
    
    switch (self.environment) {
        case RAStageEnvironment:
            env = @"Stage";
            break;
        case RAFeatureEnvironment:
            env = @"Feature";
            break;
        case RADevEnvironment:
            env = @"DEV";
            break;
        case RAQAEnvironment:
            env = @"QA";
            break;
        case RACustomEnvironment:
            env = @"Custom";
            break;
        case RAProdEnvironment:
            env = @"PROD";
            break;
            
        default:
            break;
    }
    
    return env;
}

- (BOOL)isTestServer {
    return self.environment == RAQAEnvironment;
}
    
- (BOOL)isStageServer {
    return self.environment == RAStageEnvironment;
}
    
- (BOOL)isCustomServer {
    return self.environment == RACustomEnvironment;
}

- (BOOL)isProdServer {
    return self.environment == RAProdEnvironment;
}

- (BOOL)isEmptyEnvironment {
    return self.environment == RAEmptyEnvironment;
}

@end

@implementation RAEnvironmentManager (Customization)

-(void)setCustomServerURL:(NSString *)serverURL{
    [[NSUserDefaults standardUserDefaults] setObject:serverURL forKey:kCustomServerURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.environment = RACustomEnvironment;
}

@end
