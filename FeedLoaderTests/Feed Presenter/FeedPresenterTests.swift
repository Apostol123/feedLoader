//
//  FeedPresenterTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 31/10/23.
//

import XCTest
import FeedLoader

struct FeedViewModel {
    let feed: [FeedImage]
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedView: AnyObject {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(errorView: FeedErrorView, feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    func feedDidStarLoadingFeed() {
        errorView.display(FeedErrorViewModel(message: .none))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.feedDidStarLoadingFeed()
        XCTAssertEqual(view.messages, [
            .display(errorMessages: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoadingFeed_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoadingFeed(with: feed)
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, feedLoadingView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        enum Messages: Hashable {
            case display(errorMessages: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        var messages = Set<Messages>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessages: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
