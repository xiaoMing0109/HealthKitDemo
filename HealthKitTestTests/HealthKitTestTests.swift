//
//  HealthKitTestTests.swift
//  HealthKitTestTests
//
//  Created by 怦然心动-LM on 2024/5/16.
//

import XCTest
@testable import HealthKitTest

final class HealthKitTestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

// MARK: - Heart Rate

extension HealthKitTestTests {
    
    func testHeartRate() {
        let expection = expectation(description: "Write heart rate.")

        let writeHeartRate = Double((60...100).randomElement()!)
        PLVHealthKitManager.shared.plv_writeHeartRate(writeHeartRate, date: Date()) { success, sample, error in
            if success {
                let end = Date()
                let start = end.addingTimeInterval(-3600)
                PLVHealthKitManager.shared.plv_readHeartRate(start: start, end: end) { heartRateArray in
                    XCTAssertEqual(heartRateArray?.last, writeHeartRate)
                    expection.fulfill()
                }
            } else {
                print("Write heart rate error: \(error as Any)")
                XCTFail(error?.localizedDescription ?? "Write heart rate unknown error!!!")
            }
        }
        
        wait(for: [expection], timeout: 1)
    }
}
