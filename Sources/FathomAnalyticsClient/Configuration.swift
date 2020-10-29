//
//  Configuration.swift
//  
//
//  Created by Sam Garson on 29/10/2020.
//

import Foundation
import Logging

struct Configuration {

    // MARK: Fathom config
    var siteID: String
    var environment: String
    var url: String = "https://starman.fathomdns.com"
    
    // MARK: Dependencies
    var requester: NetworkClient = FathomNetworkClient()
    var loggingBackend: (String) -> LogHandler = StreamLogHandler.standardOutput
}
