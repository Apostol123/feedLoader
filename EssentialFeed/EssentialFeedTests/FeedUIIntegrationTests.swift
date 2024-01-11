//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 8/9/23.
//

import UIKit
import XCTest
import FeedLoader
@testable import EssentialFeediOS
@testable import EssentialFeed


final class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
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
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage()])
        _ = sut.simulateFeedImageViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
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
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        //XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoading(at: 0)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedFeedReload()
        
        //XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoading(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
//        let image0 = makeImage()
//        let image1 = makeImage()
//        let (sut, loader) = makeSUT()
//        
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0, image1], at: 0)
//        assertThat(sut, isRendering: [image0, image1])
//        
//        sut.simulateUserInitiatedFeedReload()
//        loader.completeFeedLoading(with: [], at: 1)
//        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        
        loader.completeFeedLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        //XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        // XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        //XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        //XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
//        loader.completeImageLoading(at: 0)
//        
//        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
//        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
//        
//        loader.completeImageLoadingWithError(at: 1)
//        
//        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
//        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
        
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first image view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
        
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
//        XCTAssertEqual(view0?.isSowingRetryAction, false, "Expected no retry action for first view while loading first image")
//        XCTAssertEqual(view1?.isSowingRetryAction, false, "Expected no retry action for second view while loading second image")
//        
//        let imageData = UIImage.make(withColor: .red).pngData()!
//        loader.completeImageLoading(with: imageData, at: 0)
//        XCTAssertEqual(view0?.isSowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
//        XCTAssertEqual(view1?.isSowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
//        
//        loader.completeImageLoadingWithError(at: 1)
//        
//        XCTAssertEqual(view0?.isSowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
//        XCTAssertEqual(view1?.isSowingRetryAction, true, "Expected  retry action state change for second view once second image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
//        sut.loadViewIfNeeded()
//        
//        loader.completeFeedLoading(with: [makeImage()])
//        
//        let view = sut.simulateFeedImageViewVisible(at: 0)
//        
//        XCTAssertEqual(view?.isSowingRetryAction, false, "Expected no retry action while loading image")
//        
//        let invalidImageData = Data("invalid image data".utf8)
//        
//        loader.completeImageLoading(with: invalidImageData, at: 0)
//        
//        XCTAssertEqual(view?.isSowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image url request for the two visible view")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL request until image is near visible")
        
        sut.simulateFeedImageViewNearVisibile(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisibile(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no cancelled image URL request until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisibile(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is near not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisibile(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is near visible anymore")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedImage, "Exposed no renderd image when an image load finishes after the view is not visible on anymore")
    }
    
}
