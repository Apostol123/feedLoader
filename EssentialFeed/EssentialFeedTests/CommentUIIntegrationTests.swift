//
//  CommentUIIntegrationTests.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 13/1/24.
//

import XCTest
import FeedLoader
@testable import EssentialFeediOS
@testable import EssentialFeed
import Combine

final class CommentUIIntegrationTests: XCTestCase {
    func test_CommentsView_hasTitle() {
        let (sut, _) = makeCommentsSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
    
   
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeCommentsSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_loadCommentsactions_requestCommentsromLoader() {
        let (sut, loader) = makeCommentsSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1)
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, loader) = makeCommentsSUT()
        
//        sut.loadViewIfNeeded()
//
//        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
//
//        loader.completeFeedLoading(at: 0)
//
//        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
//
//        sut.simulateUserInitiatedFeedReload()
//
//        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
//
//        loader.completeFeedLoading(at: 1)
//
//        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeCommentsSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeCommentsSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeCommentsSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        
        loader.completeFeedLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeCommentsSUT()
        
//        sut.loadViewIfNeeded()
//        XCTAssertTrue(sut.isShowingLoadingIndicator)
//
//        loader.completeFeedLoading(at: 0)
//        XCTAssertFalse(sut.isShowingLoadingIndicator)
//
//        sut.simulateUserInitiatedFeedReload()
//         XCTAssertTrue(sut.isShowingLoadingIndicator)
//
//        loader.completeFeedLoadingWithError(at: 1)
//        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func makeCommentsSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, LoadResult: CommentsLoaderSpy) {
       let loader = CommentsLoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher)
       
       trackForMemoryLeaks(loader, file: file, line: line)
       trackForMemoryLeaks(sut, file: file, line: line)
       
       return (sut, loader)
   }
    
    

}

extension CommentUIIntegrationTests {
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}


class CommentsLoaderSpy {
    
    private var requests = [PassthroughSubject<[FeedImage], Error>]()

    var loadCommentsCallCount: Int {
        return requests.count
    }

    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        let publisher = PassthroughSubject<[FeedImage], Error>()
        requests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        requests[index].send(feed)
    }

    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        requests[index].send(completion: .failure(error))
    }

    // MARK: - FeedImageDataLoader

    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }

    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }

    private(set) var cancelledImageURLs = [URL]()

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
