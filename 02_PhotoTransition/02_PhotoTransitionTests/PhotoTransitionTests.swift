//
//  _2_PhotoTransitionTests.swift
//  02_PhotoTransitionTests
//
//  Created by t-sato on 2019/06/03.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import XCTest
@testable import _2_PhotoTransition

class PhotoTransitionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    /// * やりたいこと
    /// * zoomTransitionAnimatorProtocolを作るok
    /// * fromのviewのrectを計算
    /// * toのviewのrectを計算
    /// * animation前のview propaty調整 beginingAnimation
    /// * animation後のview propaty調整　finishAnimation
    /// * compreshionを呼ぶ処理をprotocolでデフォルト実装する
    /// * compresionが呼ばれたのかを確認する。stabかな？を作る
    func testPresentAnimator() {

        let zoomPresent =  ZoomTransitionForPresent()
        XCTAssertNotNil(zoomPresent)

        let view1 = UIView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
        let view2 = UIView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        let view3 = UIView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        view1.addSubview(view2)
        view2.addSubview(view3)

        let resultRect = zoomPresent.convertRreviousRect(from: view3, target: view3.bounds, to: view1)
        XCTAssertEqual(resultRect, CGRect(x: 20, y: 20, width: 100, height: 100))
        XCTAssertEqual(view3.frame, CGRect(x: 10, y: 10, width: 100, height: 100))


    }

}
