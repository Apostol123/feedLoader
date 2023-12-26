//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Alex.personal on 22/12/23.
//

import XCTest
import FeedLoader
import EssentialFeedAPI

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

    func test_load_deliversError_onClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        expect(sut, toCompleteWithResult: failure(.conectivity)) {
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon2xxHttpResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 150, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{_ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{_ in}
        sut.load{_ in}
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_delivers_Error_On2xxHttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 275, 285]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 275, 285]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .success([])) {
                let emptyListJson = makeItemItemsJson([])
                client.complete(withStatusCode: code, data: emptyListJson, at: index)
            }
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username: "a username")
        
        let item2 = makeItem(id: UUID(),
                             message: "another message",
                             createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "aanother username")
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 250, 275, 285]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .success(items)) {
                let json = makeItemItemsJson([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
        
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "www.google.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client, url: url)
        
        var capturedResult = [RemoteImageCommentsLoader.Result]()
        sut?.load(completion: {capturedResult.append($0)})
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemItemsJson([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    //MARK: Helpers
    private func makeSUT(url: URL = URL(string: "www.google.com")!, file: StaticString = #filePath, line: UInt = #line ) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteImageCommentsLoader(client: client, url: url)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
        
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComments, json: [String: Any]) {
        let item = ImageComments(id: id, message: message, createdAt: createdAt.date, username: username)
        let json = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ] as [String : Any] 
        
        
        return (item, json)
    }
    
    func makeItemItemsJson(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.load(completion: {recivedResult in
            switch (recivedResult, expectedResult) {
            case let (.success(recivedItems), .success(expectedItems)):
                XCTAssertEqual(recivedItems, expectedItems, file: file, line: line)
            case let (.failure(recivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(recivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(recivedResult)", file: file, line: line)
            }
            exp.fulfill()
        })
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
