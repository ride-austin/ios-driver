//
//  URLFactory.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/26/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import "URLFactory.h"
NSString *const kPathLogin                = @"login";
NSString *const kPathLogout               = @"logout";
NSString *const kPathPassword             = @"password";
NSString *const kPathForgot               = @"forgot";
NSString *const kPathFacebook             = @"facebook";

NSString *const kPathConfigsDriverGlobal  = @"configs/driver/global";
NSString *const kPathConfigsRiderGlobal   = @"configs/rider/global";
NSString *const kPathConfigsVersionInfo   = @"configs/app/info/current";

NSString *const kPathUsers                = @"users";
NSString *const kPathUsersSpecific        = @"users/%@";

NSString *const kPathActiveDriver         = @"acdr";
NSString *const kPathActiveDriverCurrent  = @"acdr/current";

NSString *const kPathDrivers              = @"drivers";
NSString *const kPathDriversCarTypes      = @"drivers/carTypes";
NSString *const kPathDriversCurrent       = @"drivers/current";
NSString *const kPathDriversSpecific      = @"drivers/%@";
NSString *const kPathDriversOnline        = @"drivers/%@/online";
NSString *const kPathDriversPhoto         = @"drivers/%@/photo";
NSString *const kPathDriversQueue         = @"drivers/%@/queue";
NSString *const kPathDriversReferByEmail  = @"drivers/%@/referAFriendByEmail";
NSString *const kPathDriversReferBySMS    = @"drivers/%@/referAFriendBySMS";
NSString *const kPathDriversRides         = @"drivers/%@/rides";
NSString *const kPathDriverStats          = @"drivers/%@/stats";
NSString *const kPathNewDriverConnectId   = @"drivers/%@/dcid";

NSString *const kPathDriversDocuments     = @"driversDocuments/%@";
NSString *const kPathDriversDocumentsCars = @"driversDocuments/%@/cars/%@";
NSString *const kPathDriverTypes          = @"driverTypes";

NSString *const kPathEvents               = @"events";

NSString *const kPathSurgeAreas           = @"surgeareas";

NSString *const kPathSupportTopic         = @"supporttopics/list/DRIVER";
NSString *const kPathSupportTopicChildren = @"supporttopics/%@/children";
NSString *const kPathSupportTopicForm     = @"supporttopics/%@/form";
NSString *const kPathSupportTopicMessage  = @"/rest/support/default";

NSString *const kPathLostAndFoundLost     = @"lostandfound/lost";
NSString *const kPathLostAndFoundFound    = @"lostandfound/found";
NSString *const kPathLostAndFoundContact  = @"lostandfound/contact";

NSString *const kPathQueues               = @"queues";

NSString *const kPathRideUpgradeRequest   = @"rides/upgrade/request";
NSString *const kPathRideUpgradeDecline   = @"rides/upgrade/decline";

NSString *const kPathTokens               = @"tokens";

NSString *const kPathRidesCancellation    = @"rides/cancellation";
NSString *const kPathRidesCancellationRide= @"rides/cancellation/%@";
NSString *const kPathCurrentRide          = @"rides/current";
NSString *const kPathRidesEvents          = @"rides/events";
NSString *const kPathAckReceivedRide      = @"rides/%@/received";
NSString *const kPathAcceptRide           = @"rides/%@/accept";
NSString *const kPathReachedRide          = @"rides/%@/reached";
NSString *const kPathStartRide            = @"rides/%@/start";
NSString *const kPathEndRide              = @"rides/%@/end";
NSString *const kPathSpecificRide         = @"rides/%@";
NSString *const kPathRideMap              = @"rides/%@/map";
NSString *const kPathDeclineRide          = @"rides/%@/decline";
NSString *const kPathRideRating           = @"rides/%@/rating";

NSString *const kPathPhoneVerificationRequestCode   = @"phoneVerification/requestCode";
NSString *const kPathPhoneVerificationVerify        = @"phoneVerification/verify";
