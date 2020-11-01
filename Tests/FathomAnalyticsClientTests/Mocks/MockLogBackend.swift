//
//  MockLogBackend.swift
//  
//
//  Created by Sam Garson on 30/10/2020.
//

import Foundation
import Logging
@testable import FathomAnalyticsClient

let logger = MockLogBackend()

class MockLogBackend {
    var calls = [LogCall]()

    static var lastCall: LogCall? {
        logger.calls.last
    }
    
    static func handler(label: String) -> MockLogBackend {
        return logger
    }
    
    struct LogCall {
        var message: String
        var level: Logger.Level
    }
    
    var metadata = Logger.Metadata()
    var logLevel: Logger.Level = .info
}

extension MockLogBackend: LogHandler {
    subscript(metadataKey _: String) -> Logger.Metadata.Value? {
        get { "boop" }
        set(newValue) {}
    }
    
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        calls.append(LogCall(message: "\(message)", level: level))
    }
}
