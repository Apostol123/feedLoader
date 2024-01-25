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
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeCommentsSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_loadCommentsactions_requestCommentsFromLoader() {
        let (sut, loader) = makeCommentsSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0)
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1)
        
        loader.completeCommentsLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2)
        
        loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, loader) = makeCommentsSUT()
        
        sut.simulateAppearance()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)

        loader.completeCommentsLoading(at: 0)

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)

        sut.simulateUserInitiatedReload()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)

        loader.completeCommentsLoadingWithError(at: 1)

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyComments() {
        let comment0 = makeComments(message: "message 0", username: "username 0")
        let comment1 = makeComments(message: "message 1", username: "username 1")
        let (sut, loader) = makeCommentsSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [])

        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComment() {
        let comment = makeComments(message: "a message", username: "a username")
        let (sut, loader) = makeCommentsSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComments]())
    }
    
    func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComments()
        let (sut, loader) = makeCommentsSUT()
        
        sut.simulateAppearance()
        
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        
        loader.completeCommentsLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [comment])
    }
    
    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        var sut: ListViewController?
        autoreleasepool {
             sut = CommentsUIComposer.commentsComposedWith {
                PassthroughSubject<[ImageComments], Error>()
                    .handleEvents(receiveRequest:  {_ in
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            }
            sut?.simulateAppearance()
        }
        
        XCTAssertEqual(cancelCallCount, 1)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeCommentsSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedReload()
         XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func makeCommentsSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, LoadResult: CommentsLoaderSpy) {
       let loader = CommentsLoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(loader: loader.loadPublisher)
       
       trackForMemoryLeaks(loader, file: file, line: line)
       trackForMemoryLeaks(sut, file: file, line: line)
       
       return (sut, loader)
   }
    
    func makeComments(message: String = "any message", username: String = "any username") -> ImageComments {
        return ImageComments(id: UUID(), message: message, createdAt: Date(), username: username)
   }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComments], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOFRenderedComments(), comments.count, "comments count", file: file, line: line)
        let viewModel = ImageCommentsPresenter.map(comments)
        viewModel.comments.enumerated().forEach({ index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
            
        })
    }
}

extension CommentUIIntegrationTests {
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}


class CommentsLoaderSpy {
    private var requests = [PassthroughSubject<[ImageComments], Error>]()

    var loadCommentsCallCount: Int {
        return requests.count
    }

    func loadPublisher() -> AnyPublisher<[ImageComments], Error> {
        let publisher = PassthroughSubject<[ImageComments], Error>()
        requests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeCommentsLoading(with comments: [ImageComments] = [], at index: Int = 0) {
        requests[index].send(comments)
        requests[index].send(completion: .finished)
    }

    func completeCommentsLoadingWithError(at index: Int = 0) {
        let error = anyNSError()
        requests[index].send(completion: .failure(error))
    }
}
