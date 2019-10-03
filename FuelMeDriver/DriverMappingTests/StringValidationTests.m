//
//  StringValidationTests.m
//  RideAustinTests
//
//  Created by Abdul Rehman on 18/05/2019.
//  Copyright © 2019 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Valid.h"

@interface StringValidationTests : XCTestCase

@end

@implementation StringValidationTests

-(void) testValidEmail {
    NSString * email = @"testInvalidEmail.com";
    XCTAssertFalse([email isValidEmail]);
    XCTAssertFalse([email isValidEmailBasic]);
    email = @"valid@email.com";
    XCTAssertTrue([email isValidEmail]);
    XCTAssertTrue([email isValidEmailBasic]);

}

-(void) testValidPassword {
    NSString * password = @"asdf";
    XCTAssertFalse([password isValidPassword]);
    password = @"valid1234";
    XCTAssertTrue([password isValidPassword]);
    XCTAssertTrue([[password getNumbersFromString] isEqualToString:@"1234"]);
}

-(void) testisValidConfirmationPassword {
    NSString * english = @"asdf";
    XCTAssertFalse([english isValidConfirmationPassword:@"1234"]);
    XCTAssertTrue([english isValidConfirmationPassword:@"asdf"]);
}

-(void) testValidPhone {
    NSString * phone = @"12345";
    XCTAssertFalse([phone isValidPhone]);
    XCTAssertFalse([phone isValidPhoneNumberLength]);
    phone = @"+15417543010";
    XCTAssertTrue([phone isValidPhone]);
    XCTAssertTrue([phone isValidPhoneSIN]);
    XCTAssertTrue([phone isValidPhoneNumberLength]);
}

@end
