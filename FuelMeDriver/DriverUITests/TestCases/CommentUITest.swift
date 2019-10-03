//
//  CommentUITest.swift
//  RideDriver
//
//  Created by Marcos Alba on 29/5/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest
class CommentUITest: XCTestCase {
    
    static let riderComment1 = "I’ll be waiting in front of a coffee shop, with two bags, wearing a yellow coat. I’d like you to help me with my bags, if it’s possible, please."
    static let riderComment2 = "A new comment."
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testARideCompleted() {
        let scenario: EventsScenario = .IncomingRideWithComment
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_WITH_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        sleep(2)
        testFlow.acceptRideRequest(withComment: true)
        sleep(2)
        testFlow.toggleCommentView()
        sleep(2)
        testFlow.pressArrived(withComment: true)
        sleep(2)
        testFlow.pressBeginTrip() //Asserts !comment.exists after beginTrip
        sleep(2)
        testFlow.pressEndTrip()
        testFlow.submitRating()
    }
    
    // A.  When Ride has comment, show Comment after Driver accepted. https://issue-tracker.devfactory.com/browse/RA-10811
    // https://testrail.devfactory.com//index.php?/cases/view/1189736
    
    func testA_CommentIsVisibleAfterDriverAccepted(){
        let scenario: EventsScenario = .IncomingRideWithComment
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_WITH_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest(withComment: true)
        let comment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(comment, CommentUITest.riderComment1)
    }
    
    // B. Receive new comment when Driver is on the way. https://issue-tracker.devfactory.com/browse/RA-10842
    // https://testrail.devfactory.com//index.php?/cases/view/1189738
    
    func testB_NewCommentDriverOnWay() {
        let scenario: EventsScenario = .NewCommentOnTrip
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_NEW_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        waitForElementToAppear(element: testFlow.locationVCInspector.commentLabel,timeout: 35)
        let comment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(comment, CommentUITest.riderComment2)
    }
    
    // C. Receive new comment when Driver is arrived. https://issue-tracker.devfactory.com/browse/RA-10844
    // https://testrail.devfactory.com//index.php?/cases/view/1189740
    
    func testC_NewCommentDriverArrived() {
        let scenario: EventsScenario = .NewCommentOnTrip
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_NEW_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        testFlow.pressArrived()
        waitForElementToAppear(element: testFlow.locationVCInspector.commentLabel,timeout: 35)
        let comment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(comment, CommentUITest.riderComment2)
    }
    
    // D.  Comment should be hidden once ride has started. https://issue-tracker.devfactory.com/browse/RA-10846
    // https://testrail.devfactory.com//index.php?/cases/view/1189742
    
    func testD_CommentHiddenAfterRideStarted(){
        let scenario: EventsScenario = .IncomingRideWithComment
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_WITH_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest(withComment: true)
        testFlow.pressArrived(withComment: true)
        testFlow.pressBeginTrip() //Asserts !comment.exists after beginTrip
    }
    
    // E. Should not show comment when Rider sent new comment after Driver has started the ride. https://issue-tracker.devfactory.com/browse/RA-10847
    // https://testrail.devfactory.com//index.php?/cases/view/1189741
    
    func testE_NewCommentHiddenAfterRideStarted(){
        let scenario: EventsScenario = .NewCommentOnTrip
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_NEW_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest()
        testFlow.pressArrived()
        testFlow.pressBeginTrip() //Asserts !comment.exists after beginTrip
        sleep(5)
        XCTAssertFalse(testFlow.locationVCInspector.commentLabel.exists)
    }

    //F. Receive updated comment when Driver is on the way. https://issue-tracker.devfactory.com/browse/RA-10848
    // https://testrail.devfactory.com//index.php?/cases/view/1189744
    
    func testF_CommentUpdatedWhileDriverOnWay() {
        let scenario: EventsScenario = .UpdateCommentOnTrip
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_UPDATE_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest(withComment: true)
        
        let comment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(comment, CommentUITest.riderComment1)
        
        waitForElement(element: testFlow.locationVCInspector.commentLabel,
                       predicate: NSPredicate(format: "label == '\(CommentUITest.riderComment2)'"), timeout: 10)
        
        let updatedComment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(updatedComment, CommentUITest.riderComment2)
    }
    
    // G. Receive updated comment when Driver is arrived. https://issue-tracker.devfactory.com/browse/RA-10849
    // https://testrail.devfactory.com//index.php?/cases/view/1189745
    
    func testG_CommentUpdatedWhileDriverArrived() {
        let scenario: EventsScenario = .UpdateCommentOnTrip
        let testFlow = RAUITestFlow(self, launchArguments: ["MAP_INCOMING_RIDE_UPDATE_COMMENT", scenario.rawValue])
        testFlow.launch()
        testFlow.signInSuccess()
        sleep(1)
        testFlow.goOnline()
        testFlow.waitForRideRequest()
        testFlow.acceptRideRequest(withComment: true)
        testFlow.pressArrived(withComment: true)
        
        let comment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(comment, CommentUITest.riderComment1)
        
        waitForElementToChangeValue(testFlow.locationVCInspector.commentLabel, originalValue: comment, timeout: 25)
        
        let updatedComment = testFlow.locationVCInspector.currentComment
        XCTAssertEqual(updatedComment, CommentUITest.riderComment2)
    }
    
    // H. Driver of resubmitted ride can see Rider's comment. https://issue-tracker.devfactory.com/browse/RA-10850
    // https://testrail.devfactory.com//index.php?/cases/view/1189746
    
    func testH_CommentIsVisibleAfterRideResubmitted_Skipped() {
        //From the point of view of Driver app if a ride is resubmitted it is as it was receiving a ride request from first time so it is the exactly same test as test A.
    }
}

