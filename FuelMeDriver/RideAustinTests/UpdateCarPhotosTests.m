//
//  UpdateCarPhotosTests.m
//  RideDriver
//
//  Created by Abdul Rehman on 20/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CarPhotoUpdate.h"
#import "CarPhotoUpdateCell.h"

@interface UpdateCarPhotosTests : XCTestCase

@property (nonatomic) CarPhotoUpdate *update;
@property (nonatomic) CarPhotoUpdateCell *carPhotoUpdateCell;

@end

@implementation UpdateCarPhotosTests

- (void)setUp {
    [super setUp];
    NSDictionary * testDictionary = @{@"id":@"1",
                                      @"photoUrl":@"www.google.com",
                                      @"carPhotoType":@"FRONT",
                                      @"uuid":@"12"
                                    };
    
    self.update = [[CarPhotoUpdate alloc] initWithDictionary:testDictionary];
    self.carPhotoUpdateCell = [[[NSBundle mainBundle] loadNibNamed:@"CarPhotoUpdateCell" owner:self options:nil] objectAtIndex:0];
}

- (void)testCarUpdateModelInitialization{
    XCTAssertNotNil(self.update,@"Update model initialization failed");
}

- (void)testUpdateModelProperties{
    XCTAssertEqual(self.update.photoID, @"1");
    XCTAssertEqual(self.update.UUID, @"12");
    XCTAssertEqual(self.update.imgUrl, @"www.google.com");
    XCTAssertEqual(self.update.type, FrontPhoto);
}

- (void)testPlaceHolders{
    XCTAssertEqualObjects(self.update.placeHolder, [UIImage imageNamed:@"iconCarFront"]);
    XCTAssertEqualObjects(self.update.placeHolderLarge, [UIImage imageNamed:@"iconCarFrontLarge"]);
}

- (void)testCarTypeInitializations {
    CarPhotoUpdate *front = [[CarPhotoUpdate alloc] initWithType:FrontPhoto];
    XCTAssertEqualObjects(front.placeHolder, [UIImage imageNamed:@"iconCarFront"]);
    XCTAssertEqualObjects(front.placeHolderLarge, [UIImage imageNamed:@"iconCarFrontLarge"]);
    
    CarPhotoUpdate *back = [[CarPhotoUpdate alloc] initWithType:BackPhoto];
    XCTAssertEqualObjects(back.placeHolder, [UIImage imageNamed:@"iconCarBack"]);
    XCTAssertEqualObjects(back.placeHolderLarge, [UIImage imageNamed:@"iconCarBackLarge"]);
    
    CarPhotoUpdate *inside = [[CarPhotoUpdate alloc] initWithType:InsidePhoto];
    XCTAssertEqualObjects(inside.placeHolder, [UIImage imageNamed:@"iconSeats"]);
    XCTAssertEqualObjects(inside.placeHolderLarge, [UIImage imageNamed:@"iconSeatsLarge"]);
    
    CarPhotoUpdate *trunk = [[CarPhotoUpdate alloc] initWithType:TrunkPhoto];
    XCTAssertEqualObjects(trunk.placeHolder, [UIImage imageNamed:@"iconCarTrunk"]);
    XCTAssertEqualObjects(trunk.placeHolderLarge, [UIImage imageNamed:@"iconCarTrunkLarge"]);
}

- (void) testCarPhotosUpdateCell{
    XCTAssertNotNil(self.carPhotoUpdateCell);
    self.carPhotoUpdateCell.lblTitle.text = @"Front Left";
    XCTAssertEqualObjects(self.carPhotoUpdateCell.lblTitle.text, @"Front Left");
}

@end
