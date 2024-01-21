//
//  LoadResourcePresenterPresenterTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 4/1/24.
//

import XCTest
import FeedLoader

final class LoadResourcePresenterTests: XCTestCase {

    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStarLoading()
        XCTAssertEqual(view.messages, [
            .display(errorMessages: .none),
            .display(isLoading: true)
        ])
    }
    
    func test_didFinishLoadingResource_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
                resource + " view model"
        })
        sut.didFinishLoading(with: "resource")
        XCTAssertEqual(view.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingWithMapperError_displaysLocalizedErrorMessageAndStopsLoading()  {
        let (sut, view) = makeSUT(mapper: { resource in
               throw anyError()
        })
        
        sut.didFinishLoading(with: "resource")
        XCTAssertEqual(view.messages, [
            .display(errorMessages: localized("GENERIC_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyError())
        
        XCTAssertEqual(view.messages,
                       [ .display(errorMessages: localized("GENERIC_VIEW_CONNECTION_ERROR")),
                         .display(isLoading: false)
                       ])
    }
    
    //MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<String, ViewSpy>.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private func makeSUT(
        mapper: @escaping LoadResourcePresenter<String, ViewSpy>.Mapper = {_ in "any"},
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LoadResourcePresenter<String, ViewSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter<String, ViewSpy>(errorView: view, loadingView: view, resourceView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: ResourceErrorView, ResourceLoadingView, ResourceView {
        typealias ResourceViewModel = String
        enum Messages: Hashable {
            case display(errorMessages: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        var messages = Set<Messages>()
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessages: viewModel.message))
        }
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
    }

}
