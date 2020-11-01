//
//  NetworkClient.swift
//  
//
//  Created by Sam Garson on 29/10/2020.
//

import Foundation
import Alamofire
#if canImport(UIKit)
import UIKit
#endif

protocol NetworkClient {
    func get(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) -> Void
    func post(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) -> Void
}

class FathomNetworkClient {
    private func request (method: HTTPMethod, url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .response(queue: queue) { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    private let queue = DispatchQueue.global(qos: .utility)
    private var headers: HTTPHeaders {
        ["User-Agent": userAgent]
    }
    
    private var userAgent: String {
        #if canImport(UIKit)
        let webView = UIWebView()
        return webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")!
        #else
        return "swift-app"
        #endif
    }
}

extension FathomNetworkClient: NetworkClient {
    func get(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) {
        request(method: .get, url: url, parameters: parameters, completion: completion)
    }
    
    func post(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) {
        request(method: .post, url: url, parameters: parameters, completion: completion)
    }
}
