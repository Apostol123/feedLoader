//
//  FeedStoreSpecs.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 23/8/23.
//

import Foundation
protocol FeedStoreSpecs {
    func test_retrive_deliversEmptyOnEmptyCache()
    func test_retrive_hasNoSideEffectsOnEmptyCache()
    func test_retrive_deliversFoundValuesOnNonEmptyCache()
    func test_retrivehasNoSideEffectsOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
}
