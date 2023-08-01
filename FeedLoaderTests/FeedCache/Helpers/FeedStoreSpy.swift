//
//  FeedStoreSpy.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 25/7/23.
//

import Foundation
import FeedLoader

class FeedStoreSpy: FeedStore {
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletion = [RetrievalCompletion]()

    enum RecivedMessages: Equatable {
        case deletedCachedFeed
        case insert([LocalFeedImage], Date)
        case retrive
    }

    private(set) var recivedMessages = [RecivedMessages]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        recivedMessages.append(.deletedCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }

    func insert(_ items: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recivedMessages.append(.insert(items, timeStamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletion.append(completion)
        recivedMessages.append(.retrive)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletion[index](error)
    }
}
