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
        expect(sut, toCompleteWithResult: failure(.conectivity)) {
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
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
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        }

    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "www.google.com")!)

        let item2 = makeItem(id: UUID(),
                             description: "aDescription",
                             location: "aLocation",
                             imageURL: URL(string: "www.youtube.com")!)
        let items = [item1.model, item2.model]

        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }

    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "www.google.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)

        var capturedResult = [RemoteFeedLoader.Result]()
        sut?.load(completion: {capturedResult.append($0)})

        sut = nil

        client.complete(withStatusCode: 200, data: makeItemItemsJson([]))

        XCTAssertTrue(capturedResult.isEmpty)
    }

    //MARK: Helpers
    private func makeSUT(url: URL = URL(string: "www.google.com")!, file: StaticString = #filePath, line: UInt = #line ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)

    }

    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0}

        return (item, json)
    }

    func makeItemItemsJson(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.load(completion: {recivedResult in
            switch (recivedResult, expectedResult) {
                case let (.success(recivedItems), .success(expectedItems)):
                XCTAssertEqual(recivedItems, expectedItems, file: file, line: line)
            case let (.failure(recivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(recivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(recivedResult)", file: file, line: line)
            }
            exp.fulfill()
        })
        action()

        wait(for: [exp], timeout: 1.0)
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

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLS[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
