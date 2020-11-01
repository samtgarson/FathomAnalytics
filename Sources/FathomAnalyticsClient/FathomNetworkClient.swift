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
    func get(_ url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) -> Void
    func post(_ url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) -> Void
}

class FathomNetworkClient {
    internal init(session: Session = Session.default) {
        self.session = session
    }
    
    let session: Session
    
    func request (method: HTTPMethod, url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) {
        session.request(url, method: .get, parameters: parameters)
            .validate()
            .responseString(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
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
    func get(_ url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) {
        request(method: .get, url: url, parameters: parameters, completion: completion)
    }
    
    func post(_ url: String, parameters: Parameters?, completion: @escaping (Result<String, Error>) -> Void) {
        request(method: .post, url: url, parameters: parameters, completion: completion)
    }
}
