//
//  RADocument.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 1/18/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RADocument : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSNumber *cityID;
@property (nonatomic, readonly) NSString *documentStatus;
@property (nonatomic, readonly) NSString *documentType;
@property (nonatomic, readonly) NSURL *documentURL;
@property (nonatomic, readonly) NSNumber *documentID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *notes;
@property (nonatomic, readonly) BOOL removed;
@property (nonatomic) NSDate *validityDate;

@end
/**
 *
 *  SAMPLE
 *
    {
        cityId = 1;
        documentStatus = APPROVED;
        documentType = LICENSE;
        documentUrl = "https://s3.amazonaws.com/media-stage.rideaustin.com/driver-licenses/a43027af-fc9e-447c-bf7d-b157ace57cc6.png?AWSAccessKeyId=AKIAJRZKPEUYYX2JFKEA&Expires=1484765617&Signature=Pj9j3Ntz2c0v5eW7ikRBrTDFuN0%3D";
        id = 5005;
        name = "";
        removed = 0;
        validityDate = 1553212800000;
    }
 */
