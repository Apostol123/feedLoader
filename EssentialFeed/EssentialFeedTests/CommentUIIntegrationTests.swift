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

final class CommentUIIntegrationTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = makeCommentsSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
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
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeCommentsSUT()
        XCTAssertEqual(loader.feedLoadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.feedLoadCallCount, 1)
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.feedLoadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.feedLoadCallCount, 3)
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
        
        sut.simulateUserInitiatedFeedReload()
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
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeCommentsSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        
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
    
    func makeCommentsSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, LoadResult: LoaderSpy) {
       let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher)
       
       trackForMemoryLeaks(loader, file: file, line: line)
       trackForMemoryLeaks(sut, file: file, line: line)
       
       return (sut, loader)
   }
    
    

}
