//
//  FeedLoaderCoreDataTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 26/8/23.
//

import XCTest
import FeedLoader

final class FeedLoaderCoreDataTests: XCTestCase, FeedStoreSpecs {
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrive_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrivehasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    //MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
            let sut = CoreDataFeedStore()
            trackForMemoryLeaks(sut, file: file, line: line)
            return sut
        }
}
