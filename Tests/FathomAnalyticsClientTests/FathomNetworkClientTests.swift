//
//  FathomNetworkClientTests.swift
//  
//
//  Created by Sam Garson on 01/11/2020.
//

import XCTest
import Alamofire
import Mocker
@testable import FathomAnalyticsClient

func createSession() -> Session {
    let configuration = URLSessionConfiguration.af.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    return Alamofire.Session(configuration: configuration)
}

let session = createSession()
let client = FathomNetworkClient(session: session)
let methods = [client.get, client.post]

final class FathomNetworkClientTests: XCTestCase {
    
    override class func setUp() {
        Mock(
            url: URL(string: "https://www.example.com/success?bar=baz")!,
            dataType: .imagePNG,
            statusCode: 200,
            data: [
                .get: "response".data(using: .utf8)!,
                .post: "response".data(using: .utf8)!
            ]
        ).register()
        
        Mock(
            url: URL(string: "https://www.example.com/failure?bar=baz")!,
            dataType: .imagePNG,
            statusCode: 500,
            data: [
                .get: "response".data(using: .utf8)!,
                .post: "response".data(using: .utf8)!
            ]
        ).register()
        
        Mock(
            url: URL(string: "https://www.example.com/error?bar=baz")!,
            dataType: .imagePNG,
            statusCode: 500,
            data: [
                .get: "response".data(using: .utf8)!,
                .post: "response".data(using: .utf8)!
            ],
            requestError: MockNetworkClient.MockNetworkError.oops
        ).register()
    }
    
    func testSuccess() {
        methods.forEach { method in
            let expectation = XCTestExpectation(description: "Test successful request")
            
            method("https://www.example.com/success", ["bar": "baz"]) { result in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data, "response")
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testFailure() {
        methods.forEach { method in
            let expectation = XCTestExpectation(description: "Test failed request")
            
            method("https://www.example.com/failure", ["bar": "baz"]) { result in
                switch result {
                case .success(let data):
                    XCTFail("Expected 500 to cause failure, received: \(data)")
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription, "Response status code was unacceptable: 500.")
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testError() {
        methods.forEach { method in
            let expectation = XCTestExpectation(description: "Test error request")
            
            client.get("https://www.example.com/error", parameters: ["bar": "baz"]) { result in
                switch result {
                case .success(let data):
                    XCTFail("Expected 500 to cause failure, received: \(data)")
                case .failure(let error):
                    XCTAssert(error.localizedDescription.contains("URLSessionTask failed with error: The operation couldn’t be completed."))
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
}
