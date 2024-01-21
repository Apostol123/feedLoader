//
//  Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 5/12/23.
//
import UIKit
import XCTest
import FeedLoader
import EssentialFeed
import Combine
@testable import EssentialFeediOS


extension FeedUIIntegrationTests {
    func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()

        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }

        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }

        executeRunLoopToCleanUpReferences()
    }

    func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)

        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "isShowingLocation at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.locationText, image.location, "location at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.descriptionText, image.description, "description at index (\(index)", file: file, line: line)
    }

    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}


extension XCTestCase {
    // MARK: - Helpers
    
     func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    func makeSUT(
        selection: @escaping (FeedImage) -> Void = {_ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ListViewController, LoadResult: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            loader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection
        )
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
     func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location ,url: url)
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
         var feedLoadCallCount: Int  {
            feedRequests.count
        }
        
        private var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledImageURLs: [URL] = []
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0 ) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        var loadedImageURLs: [URL] {
            return imageRequest.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequest.append((url: url, completion: completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url)}
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequest[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an erro", code: 0)
            imageRequest[index].completion(.failure(error))
        }
    }

}

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isSowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}

extension UIButton {
    func simulateTap() {
       allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ valueChanged in
                (target as NSObject).perform(Selector(valueChanged))
            })
        })
    }
}

 extension UIRefreshControl {
    func simulatePullToRefresh() {
       allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ valueChanged in
                (target as NSObject).perform(Selector(valueChanged))
            })
        })
    }
}

 extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
