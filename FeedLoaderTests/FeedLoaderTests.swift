//
//  FeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 8/6/23.
//

import XCTest
import FeedLoader
final class RemoteFeedLoaderTests: XCTestCase {

    func test_load_deliversError_onClientError() {
       let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load(completion: {capturedError.append($0)})
        client.complete(with: clientError)
        XCTAssertEqual(capturedError, [.conectivity])
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load(completion: {capturedError.append($0)})
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedError, [.invalidData])
        }
    }


    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLS.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load{_ in}
        XCTAssertEqual(client.requestedURLS, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load{_ in}
        sut.load{_ in}
        XCTAssertEqual(client.requestedURLS, [url, url])
    }

    func test_load_delivers_Error_On200HttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load(completion: {capturedError.append($0)})

        let invalidJSON = Data("invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
        XCTAssertEqual(capturedError, [.invalidData])
    }

    //MARK: Helpers
    private func makeSUT(url: URL = URL(string: "www.google.com")! ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(client: client, url: url)
        return (sut, client)

    }

    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLS: [URL] {
            return messages.map({$0.url})
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLS[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(response))
        }
    }
}
