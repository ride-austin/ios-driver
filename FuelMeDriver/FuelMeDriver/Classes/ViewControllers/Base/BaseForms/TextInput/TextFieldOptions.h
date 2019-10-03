//
//  TextFieldOptions.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TextFieldInputType) {
    letters             = 1 << 0,
    lettersLOWERCASE    = 1 << 1,
    lettersUPPERCASE    = 1 << 2,
    numbersEN           = 1 << 3,
    punctuations        = 1 << 4,
    symbols             = 1 << 5,
    symbols1            = 1 << 6,
    symbols2            = 1 << 7,
    symbols3            = 1 << 8,
    symbolsEmail        = 1 << 9,
    space               = 1 << 10,
    backSlash           = 1 << 11
};

@interface TextFieldOptions : NSObject
+(NSString *)validCharactersForTypes:(TextFieldInputType)inputTypes;
@end
