//
//  FathomAnalyticsClientTests.swift
//
//
//  Created by Sam Garson on 29/10/2020.
//

import XCTest
@testable import FathomAnalyticsClient

final class FathomAnalyticsClientTests: XCTestCase {
    let siteID = "siteID"
    let environment = "production"
    let url = "url"
    
    func testConfiguration() {
        let basic = FathomAnalyticsClient(with: Configuration(siteID: siteID, environment: environment))
        let withUrl = FathomAnalyticsClient(with: Configuration(siteID: siteID, environment: environment, url: url))
        let withLogger = FathomAnalyticsClient(with: Configuration(siteID: siteID, environment: environment, loggingBackend: MockLogBackend.handler))
        
        XCTAssertNotNil(basic)
        XCTAssertNotNil(withUrl)
        XCTAssertNotNil(withLogger)
    }
    
    func testTrackPage() {
        let page = "my page"
        let networkClient = MockNetworkClient()
        let config = Configuration(siteID: siteID, environment: environment, url: url, requester: networkClient, loggingBackend: MockLogBackend.handler)
        let client = FathomAnalyticsClient(with: config)
        
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
        let config = Configuration(siteID: siteID, environment: environment, url: url, requester: networkClient, loggingBackend: MockLogBackend.handler)
        let client = FathomAnalyticsClient(with: config)
        
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
        let config = Configuration(siteID: siteID, environment: environment, url: url, requester: networkClient, loggingBackend: MockLogBackend.handler)
        let client = FathomAnalyticsClient(with: config)
        
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
        let config = Configuration(siteID: siteID, environment: environment, url: url, requester: networkClient, loggingBackend: MockLogBackend.handler)
        let client = FathomAnalyticsClient(with: config)
        
        networkClient.failNextCall()
        client.track(goal: goal, value: value)
        
        let lastLog = MockLogBackend.lastCall
        XCTAssertEqual(lastLog?.level, .error)
        XCTAssert((lastLog?.message.contains("Failed to track goal \(goal)")) ?? false)
    }
}
