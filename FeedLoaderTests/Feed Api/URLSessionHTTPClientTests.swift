//
//  URLSessionHTTPClientTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 15/6/23.
//

import XCTest
import FeedLoader

final class URLSessionHTTPClientTests: XCTestCase {

    override  func setUp() {
        URLProtocolStub.startInterceptionRequests()
    }

    override  func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "www.google.com")!
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url, completion: {_ in})
        wait(for: [exp], timeout: 1.0)
    }


    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        guard let recivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError else {
            XCTFail("Expected NSerror but got \(String(describing: resultErrorFor(data: nil, response: nil, error: requestError))) instead")
            return
        }
        XCTAssertEqual(recivedError.domain, requestError.domain)
        XCTAssertEqual(recivedError.code, requestError.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
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
        let recivedValues = resultValuesFor(data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(emptyData, recivedValues?.data)
        XCTAssertEqual(response.url, recivedValues?.httpResponse.url)
        XCTAssertEqual(response.statusCode, recivedValues?.httpResponse.statusCode)
    }


    // MARK: - Helpers

    private func anyError() -> Error {
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

    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, httpResponse: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
            switch result {
            case .success(let data, let response):
                return (data, response)
            default:
                XCTFail("Expected sucess  got \(result) instead", file: file, line: line)
                return nil
            }
    }

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
            switch result {
            case .failure(let error):
                return error
            default:
                XCTFail("Expected failure  got \(result) instead", file: file, line: line)
                return nil
            }
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        URL(string: "www.google.com")!
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }

        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptionRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(error: error, data: data, response: response)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }

}
