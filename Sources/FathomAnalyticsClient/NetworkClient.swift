//
//  NetworkClient.swift
//  
//
//  Created by Sam Garson on 29/10/2020.
//

import Foundation
import Alamofire

protocol NetworkClient {
    func request(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) -> Void
}

class FathomNetworkClient: NetworkClient {
    func request(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request(url, parameters: parameters)
            .validate()
            .response(queue: queue) { response in
                print("Executed on utility queue.")
            }
    }
    
    private let queue = DispatchQueue.global(qos: .utility)
}
