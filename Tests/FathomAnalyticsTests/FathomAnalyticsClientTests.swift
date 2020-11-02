//
//  FathomAnalyticsTests.swift
//
//
//  Created by Sam Garson on 29/10/2020.
//

import XCTest
@testable import FathomAnalytics

final class FathomAnalyticsClientTests: XCTestCase {
    let siteID = "siteID"
    let environment = "production"
    let url = "url"
    
    func testFathomConfiguration() {
        let basic = FathomAnalyticsClient(siteID: siteID, environment: environment)
        let withUrl = FathomAnalyticsClient(siteID: siteID, environment: environment, url: url)
        let withLogger = FathomAnalyticsClient(siteID: siteID, environment: environment, logger: MockLogBackend.handler)
        
        XCTAssertNotNil(basic)
        XCTAssertNotNil(withUrl)
        XCTAssertNotNil(withLogger)
    }
    
    func testTrackPage() {
        let page = "my page"
        let networkClient = MockNetworkClient()
        let client = FathomAnalyticsClient(siteID: siteID, environment: environment, url: url, logger: MockLogBackend.handler, networkClient: networkClient)
        
        client.track(page: page)
        
        let lastCall = networkClient.calls.last
        XCTAssertEqual(lastCall?.url, url)
        XCTAssertEqual(lastCall?.method, .get)
        XCTAssertEqual(lastCall?.parameters as? [String: String], [
            "sid": siteID,
            "h": environment,
            "p": page,
            "res": ""
        ])
        
        let lastLog = MockLogBackend.lastCall
        XCTAssertEqual(lastLog?.level, .info)
        XCTAssertEqual(lastLog?.message, "Tracked page \(page)")
    }
    
    
    func testFailedTrackPage() {
        let page = "my page"
        let networkClient = MockNetworkClient()
        let client = FathomAnalyticsClient(siteID: siteID, environment: environment, url: url, logger: MockLogBackend.handler, networkClient: networkClient)
        
        networkClient.failNextCall()
        client.track(page: page)
        
        let lastLog = MockLogBackend.lastCall
        XCTAssertEqual(lastLog?.level, .error)
        XCTAssert(lastLog?.message.contains("Failed to track page \(page)") ?? false)
    }
    
    func testTrackGoal() {
        let goal = "goal code"
        let value = 2
        let networkClient = MockNetworkClient()
        let client = FathomAnalyticsClient(siteID: siteID, environment: environment, url: url, logger: MockLogBackend.handler, networkClient: networkClient)
        
        client.track(goal: goal, value: value)
        
        let lastCall = networkClient.calls.last
        XCTAssertEqual(lastCall?.url, url)
        XCTAssertEqual(lastCall?.method, .post)
        XCTAssertEqual(lastCall?.parameters as? [String: String], [
            "gcode": goal,
            "gval": "\(value)"
        ])
        
        let lastLog = MockLogBackend.lastCall
        XCTAssertEqual(lastLog?.level, .info)
        XCTAssertEqual(lastLog?.message, "Tracked goal \(goal)")
    }
    
    
    func testFailedTrackGoal() {
        let goal = "goal code"
        let value = 2
        let networkClient = MockNetworkClient()
        let client = FathomAnalyticsClient(siteID: siteID, environment: environment, url: url, logger: MockLogBackend.handler, networkClient: networkClient)
        
        networkClient.failNextCall()
        client.track(goal: goal, value: value)
        
        let lastLog = MockLogBackend.lastCall
        XCTAssertEqual(lastLog?.level, .error)
        XCTAssert((lastLog?.message.contains("Failed to track goal \(goal)")) ?? false)
    }
}
