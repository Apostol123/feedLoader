//
//  RemoteLoaderTests.swift
//  EssentialFeedAPITests
//
//  Created by Alex.personal on 29/12/23.
//

import XCTest
import FeedLoader
import EssentialFeedAPI

final class RemoteLoaderTests: XCTestCase {

    
    func test_load_deliversError_onClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        expect(sut, toCompleteWithResult: failure(.conectivity)) {
            client.complete(with: clientError)
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
    
    func test_load_delivers_Error_OnMapperError() {
        let (sut, client) = makeSUT(mapper: {  _, _ in
            throw self.anyError()
        } )
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversMappedResource() {
        let resource = "a resource"
        
        let (sut, client) = makeSUT(mapper: {data,_ in
            String(data: data, encoding: .utf8)!
        })
       
        
        
        expect(sut, toCompleteWithResult: .success(resource), when:  {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        })
        
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "www.google.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(client: client, url: url, mapper: {_,_ in "any"})
        
        var capturedResult = [RemoteLoader<String>.Result]()
        sut?.load(completion: {capturedResult.append($0)})
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemItemsJson([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    //MARK: Helpers
   
    private func makeSUT(
        url: URL = URL(string: "www.google.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = {_,_ in "any"},
        file: StaticString = #filePath,
        line: UInt = #line ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
            let sut =  RemoteLoader<String>(client: client, url: url, mapper: mapper)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
        
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
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
    
    private func expect(_ sut: RemoteLoader<String>, toCompleteWithResult expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.load(completion: {recivedResult in
            switch (recivedResult, expectedResult) {
            case let (.success(recivedItems), .success(expectedItems)):
                XCTAssertEqual(recivedItems, expectedItems, file: file, line: line)
            case let (.failure(recivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(recivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(recivedResult)", file: file, line: line)
            }
            exp.fulfill()
        })
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func anyError() -> NSError {
        return NSError(domain: "www.anydomain.com", code: 1)
    }

}
