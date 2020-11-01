//
//  MockNetworkClient.swift
//  
//
//  Created by Sam Garson on 30/10/2020.
//

import Foundation
import Alamofire
@testable import FathomAnalyticsClient

class MockNetworkClient {
    private var failNext = false
    
    private func request(_ method: HTTPMethod, url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) {
        calls.append(NetworkRequest(method: method, url: url, parameters: parameters))
        
        if failNext {
            failNext = false
            completion(.failure(MockNetworkError.oops))
        } else {
            completion(.success("response"))
        }
    }
    
    var calls = [NetworkRequest]()
    
    func failNextCall () {
        self.failNext = true
    }

    struct NetworkRequest {
        let method: HTTPMethod
        let url: String
        let parameters: Parameters?
    }
    
    enum MockNetworkError: Error {
        case oops
    }
}

extension MockNetworkClient: NetworkClient {
    func get(_ url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) {
        request(.get, url: url, parameters: parameters, completion: completion)
    }
    
    func post(_ url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) {
        request(.post, url: url, parameters: parameters, completion: completion)
    }
}
