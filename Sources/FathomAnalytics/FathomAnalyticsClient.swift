//
//  FathcomAnalyticsClient.swift
//
//
//  Created by Sam Garson on 29/10/2020.
//

import Foundation
import Logging
#if canImport(UIKit)
import UIKit
#endif

public final class FathomAnalyticsClient {
    internal init(
        siteID: String,
        environment: String,
        url: String,
        logger: (String) -> LogHandler,
        networkClient: NetworkClient
    ) {
        self.siteID = siteID
        self.environment = environment
        self.url = url
        self.logger = Logger(label: "FathomAnalytics", factory: logger)
        self.requester = networkClient
    }
    
    public convenience init(
        siteID: String,
        environment: String,
        url: String = "https://starman.fathomdns.com",
        logger: (String) -> LogHandler = StreamLogHandler.standardOutput
    ) {
        self.init(
            siteID: siteID,
            environment: environment,
            url: url,
            logger: logger,
            networkClient: FathomNetworkClient()
        )
    }
    
    private var siteID: String
    private var environment: String
    private var url: String
    private var logger: Logger
    private var requester: NetworkClient
}

// MARK: Page tracking
extension FathomAnalyticsClient {
    public func track(page name: String) {
        requester.get(url, parameters: parameters(for: name)) { result in
            switch result {
            case .failure(let error):
                self.logger.error("Failed to track page \(name): \(error.localizedDescription)")
            case .success:
                self.logger.info("Tracked page \(name)")
            }
        }
    }

    private func parameters(for page: String) -> [String: String] {
        [
            "sid": siteID,
            "h": environment,
            "p": page,
            "res": resolution
        ]
    }
    
    private var resolution: String {
        #if canImport(UIKit)
        let bounds = UIScreen.main.bounds
        return "\(bounds.width)x\(bounds.height)"
        #else
        return ""
        #endif
    }
}

// MARK: Goal tracking
extension FathomAnalyticsClient {
    public func track(goal code: String, value: Int = 0) {
        requester.post(url, parameters: parameters(for: code, value: value)) { result in
            switch result {
            case .failure(let error):
                self.logger.error("Failed to track goal \(code): \(error.localizedDescription)")
            case .success:
                self.logger.info("Tracked goal \(code)")
            }
        }
    }
    
    private func parameters(for goal: String, value: Int) -> [String: String] {
        [
            "gcode": goal,
            "gval": "\(value)"
        ]
    }
}
