import XCTest
import Alamofire
import Logging
@testable import FathomAnalyticsClient

class TestLogBackend: LogHandler {
    subscript(metadataKey _: String) -> Logger.Metadata.Value? {
        get { "boop" }
        set(newValue) {}
    }
    
    var metadata = Logger.Metadata()
    var logLevel: Logger.Level = .info
    
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        print(message)
    }

    static func handler(label: String) -> TestLogBackend {
        return TestLogBackend()
    }
}

class MockNetworkClient: NetworkClient {
    private var failNextCase = false
    
    func request(_ url: String, parameters: Parameters?, completion: @escaping (Result<Void, Error>) -> Void) {
        calls.append(NetworkRequest(url: url, parameters: parameters))
        
        if failNextCase {
            completion(.failure(NSError()))
            failNextCase = false
        } else {
            completion(.success(()))
        }
    }
    
    var calls = [NetworkRequest]()
    
    struct NetworkRequest {
        let url: String
        let parameters: Parameters?
    }
}

final class FathomAnalyticsClientTests: XCTestCase {
    let siteID = "siteID"
    let environment = "production"
    let url = "url"
    
    func testConfiguration() {
        let basic = FathomAnalyticsClient(with: Configuration(siteID: siteID, environment: environment))
        let withUrl = FathomAnalyticsClient(with: Configuration(siteID: siteID, environment: environment, url: url))
        let withLogger = FathomAnalyticsClient(with: Configuration(siteID: siteID, environment: environment, loggingBackend: TestLogBackend.handler))
        
        XCTAssertNotNil(basic)
        XCTAssertNotNil(withUrl)
        XCTAssertNotNil(withLogger)
    }
    
    func testTrackPage() {
        let page = "my page"
        let networkClient = MockNetworkClient()
        let config = Configuration(siteID: siteID, environment: environment, url: url, requester: networkClient)
        let client = FathomAnalyticsClient(with: config)
        
        client.track(page: page)
        
        let lastCall = networkClient.calls.first
        XCTAssertEqual(lastCall?.url, url)
        XCTAssertEqual(lastCall?.parameters as? [String: String], [
            "sid": siteID,
            "h": environment,
            "p": page,
            "res": ""
        ])
    }
}
