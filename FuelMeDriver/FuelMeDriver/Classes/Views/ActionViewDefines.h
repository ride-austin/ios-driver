//
//  ActionViewDefines.h
//  RideDriver
//
//  Created by Carlos Alcala on 11/17/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#ifndef ActionViewDefines_h
#define ActionViewDefines_h

typedef enum : NSUInteger {
    Arrived     = 0,    //to show Arrived
    Begin       = 1,    //to show Begin Trip
    End         = 2,    //to show End Trip
    Idle        = 3     //(to avoid display any button)
} ActionType;

@protocol ActionViewDelegate <NSObject>

- (void)actionViewDidTap:(UIButton*)sender withAction:(ActionType)type;

@end


#endif /* ActionViewDefines_h */
