//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Alex.personal on 22/12/23.
//

import XCTest
import FeedLoader
import EssentialFeedAPI

final class ImageCommentsMapperTests: XCTestCase {
    func test_map_deliversErrorOnNon2xxHttpResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        let json = makeItemItemsJson([])
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_delivers_Error_On2xxHttpResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        let samples = [200, 201, 250, 275, 285]
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let samples = [200, 201, 250, 275, 285]
        let emptyListJson = makeItemItemsJson([])
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListJson, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                             username: "a username")
        
        let item2 = makeItem(id: UUID(),
                             message: "another message",
                             createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                             username: "aanother username")
        let items = [item1.model, item2.model]
        
        let json = makeItemItemsJson([item1.json, item2.json])
        
        let samples = [200, 201, 250, 275, 285]
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }
    }
    
   
    
    //MARK: Helpers

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
}
