//
//  FathcomAnalyticsClient.swift
//
//
//  Created by Sam Garson on 29/10/2020.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public final class FathomAnalyticsClient {
    init(with config: Configuration) {
        self.config = config
        
        LogBootstrapper.bootstrap(config.loggingBackend)
    }
    
    private var config: Configuration
    
    func track(page name: String) {
        config.requester.request(config.url, parameters: parameters(for: name)) { result in
            switch result {
            case .failure(let error):
                print("Failed to track page \(name): \(error)")
            case .success:
                print("Tracked page \(name)")
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
