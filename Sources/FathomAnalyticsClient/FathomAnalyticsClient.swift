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
    init(with config: Configuration) {
        self.config = config
        self.logger = Logger(label: "FathomAnalyticsClient", factory: config.loggingBackend)
    }
    
    private let config: Configuration
    private let logger: Logger
}

extension FathomAnalyticsClient {
    func track(page name: String) {
        config.requester.get(config.url, parameters: parameters(for: name)) { result in
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
            "sid": config.siteID,
            "h": config.environment,
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

extension FathomAnalyticsClient {
    func track(goal code: String, value: Int = 0) {
        config.requester.post(config.url, parameters: parameters(for: code, value: value)) { result in
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
