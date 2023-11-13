//
//  URLSessionHTTPClientTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 15/6/23.
//

import XCTest
import FeedLoader

final class URLSessionHTTPClientTests: XCTestCase {
    
    
    
    override  func tearDown() {
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "www.google.com")!
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url, completion: {_ in})
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { _ in exp.fulfill() }
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        let exp = expectation(description: "wait for request")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .success(let recivedData, let recivedResponse):
                XCTAssertEqual(data, recivedData)
                XCTAssertEqual(response.url, recivedResponse.url)
                XCTAssertEqual(response.statusCode, recivedResponse.statusCode)
            default:
                XCTFail("expected succes \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_suceedsWithEmprtDataOnHTTPURLResponseNilData() {
        
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    
    // MARK: - Helpers
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse{
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyData() -> Data {
        Data(count: 20)
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion block")
        var recivedResult: HTTPClient.Result!
        sut.get(from: anyURL()) {result in
            recivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return recivedResult
        
    }
    
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
            let result = resultFor(values, file: file, line: line)
            switch result {
            case let .success(data, response):
                return (data, response)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
                return nil
            }
        }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
            values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

            let sut = makeSUT(file: file, line: line)
            let exp = expectation(description: "Wait for completion")

            var receivedResult: HTTPClient.Result!
            taskHandler(sut.get(from: anyURL()) { result in
                receivedResult = result
                exp.fulfill()
            })

            wait(for: [exp], timeout: 1.0)
            return receivedResult
        }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error? {
            let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)

            switch result {
            case let .failure(error):
                return error
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
                return nil
            }
        }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [URLProtocolStub.self]
            let session = URLSession(configuration: configuration)

            let sut = URLSessionHTTPClient(session: session)
            trackForMemoryLeaks(sut, file: file, line: line)
            return sut
        }
    
    private func anyURL() -> URL {
        URL(string: "www.google.com")!
    }
    
}
