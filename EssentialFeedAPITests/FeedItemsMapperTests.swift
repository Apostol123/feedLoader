//
//  FeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 8/6/23.
//

import XCTest
import FeedLoader
import EssentialFeedAPI
final class FeedItemsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HttpResponse() throws {
        let samples = [199, 201, 300, 400, 500]
        let json = makeItemItemsJson([])
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsError_On200HttpResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJson = makeItemItemsJson([])
        
        let result = try FeedItemsMapper.map(emptyListJson, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "www.google.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "aDescription",
                             location: "aLocation",
                             imageURL: URL(string: "www.youtube.com")!)
        let items = [item1.model, item2.model]
        let json = makeItemItemsJson([item1.json, item2.json])
        
        let result = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, items)
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
   
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
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
    
}
func anyURL() -> URL {
   URL(string: "www.google.com")!
}

extension HTTPURLResponse {
    
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
