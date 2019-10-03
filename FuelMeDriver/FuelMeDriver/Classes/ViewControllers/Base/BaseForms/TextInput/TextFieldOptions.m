//
//  TextFieldOptions.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TextFieldOptions.h"

NSString * const VClettersLOWERCASE  = @"abcdefghijklmnopqrstuvwxyz";
NSString * const VClettersUPPERCASE  = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
NSString * const VCnumbersEN     = @"0123456789";
NSString * const VCpunctuations  = @" .,?!'";
NSString * const VCsymbols1      = @"-/:;()$&@";
NSString * const VCsymbols2      = @"[]{}#%^*+=";
NSString * const VCsymbols3      = @"_\\|~<>€£¥•";
NSString * const VCsymbolsEmail   = @"_-@.";
NSString * const VCspace         = @" ";
NSString * const VCBackSlash     = @"/";

@implementation TextFieldOptions
+(NSString *)validCharactersForTypes:(TextFieldInputType)inputTypes {
    NSMutableString *validChars = [NSMutableString new];
    if (inputTypes & letters) {
        [validChars appendString:VClettersUPPERCASE];
        [validChars appendString:VClettersLOWERCASE];
    }
    if (inputTypes & lettersLOWERCASE) {
        [validChars appendString:VClettersLOWERCASE];
    }
    if (inputTypes & lettersUPPERCASE) {
        [validChars appendString:VClettersUPPERCASE];
    }
    if (inputTypes & numbersEN) {
        [validChars appendString:VCnumbersEN];
    }
    if (inputTypes & punctuations) {
        [validChars appendString:VCpunctuations];
    }
    if (inputTypes & symbols) {
        [validChars appendString:VCsymbols1];
        [validChars appendString:VCsymbols2];
        [validChars appendString:VCsymbols3];
    }
    if (inputTypes & symbols1) {
        [validChars appendString:VCsymbols1];
    }
    if (inputTypes & symbols2) {
        [validChars appendString:VCsymbols2];
    }
    if (inputTypes & symbols3) {
        [validChars appendString:VCsymbols3];
    }
    if (inputTypes & symbolsEmail) {
        [validChars appendString:VCsymbolsEmail];
    }
    if (inputTypes & space) {
        [validChars appendString:VCspace];
    }
    if (inputTypes & backSlash) {
        [validChars appendString:VCBackSlash];
    }
    return validChars.copy;
}
@end
