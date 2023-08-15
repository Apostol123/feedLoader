//
//  CodableFeedStoreTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 15/8/23.
//

import XCTest
import FeedLoader

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

    func test_retrive_deliversOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for expectation")
        
        sut.retrieve(completion: { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for expectation")
        sut.retrieve(completion: { firstResult in
            sut.retrieve(completion: { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result, got \([firstResult, secondResult]) instead")
                }
                
                exp.fulfill()
            })
        })
        
        
        wait(for: [exp], timeout: 1.0)
    }
}
