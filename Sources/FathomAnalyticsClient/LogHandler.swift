//
//  LogHandler.swift
//  
//
//  Created by Sam Garson on 29/10/2020.
//

import Foundation
import Logging

typealias LogFactory = (String) -> LogHandler

struct LogBootstrapper {
    private static var handlerIsInitialized = false
    private static let initializeHandlerDispatchQueue = DispatchQueue(
        label: "FathomAnalyticsClientLogger.initializeHandler"
    )
    
    static func bootstrap(_ logFactory: @escaping LogFactory) {
        self.initializeHandlerDispatchQueue.sync {
            if self.handlerIsInitialized { return }
        
            LoggingSystem.bootstrap(logFactory)
            self.handlerIsInitialized = true
        }
    }
}
