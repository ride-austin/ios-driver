//
//  SplashViewControllerUITest.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/16/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import XCTest

class SplashViewControllerUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSplashFromFreshInstall() {
        let testFlow = RAUITestFlow(self)
        testFlow.launch()
        
        let splashView = testFlow.splashVCInspector.splashView
        passedWhenElementAppears(element: splashView)
        
        testFlow.splashVCInspector.assertSplashView()
    }
    
    func testSplashWhenSignout() {
        let testFlow = RAUITestFlow(self,launchArguments: [])
        testFlow.launch()
        
        testFlow.signInSuccess()
        testFlow.signOut()
        
        let splashView = testFlow.splashVCInspector.splashView
        passedWhenElementAppears(element: splashView,timeout: 15)
        
        testFlow.splashVCInspector.assertSplashView()
    }
}
