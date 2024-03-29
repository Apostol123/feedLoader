//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 12/12/23.
//

import XCTest
@testable import FeedLoader
@testable import EssentialFeediOS


final class FeedSnapshotTests: XCTestCase {
    
   
    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_FeedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "ErrorMessage"))
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_DARK")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_LIGHT")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithImageFailedLoading())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()

        sut.display(feedWithLoadMoreIndicator())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }

    func test_feedWithLoadMoreError() {
        let sut = makeSUT()

        sut.display(feedWithLoadMoreError())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_LOAD_MORE_Error_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_LOAD_MORE_Error_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_Error_dark_extraExtraExtraLarge")
    }
    
    //MARK: - Helpers
    
    
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return feedWith(loadMore: loadMore)
    }

    private func feedWithLoadMoreError() -> [CellController] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(ResourceErrorViewModel(message: "This is a multiline\nerror message"))
        return feedWith(loadMore: loadMore)
    }

    private func feedWith(loadMore: LoadMoreCellController) -> [CellController] {
        let stub = feedWithContent().first!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = cellController

        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
        ]
    }
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyBoard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyFeed() ->  [FeedImageCellController] {
        return []
    }
    
    
    
    private func feedWithImageFailedLoading() -> [ImageStub] {
        return [ ImageStub(
            description: nil,
            location: "Cannon Street Londong",
            image: nil
        ),
                 ImageStub(
                    description: nil,
                    location: "Brighton Seafron",
                    image: nil
                 )
        ]
    }
    
    private func feedWithContent() -> [ImageStub] {
            return [
                ImageStub(
                    description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    location: "East Side Gallery\nMemorial in Berlin, Germany",
                    image: UIImage.make(withColor: .red)
                ),
                ImageStub(
                    description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    location: "Garth Pier",
                    image: UIImage.make(withColor: .green)
                )
            ]
        }

}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        }

        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            description: description,
            location: location)
        self.image = image
    }

    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))

        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }

    func didCancelImageRequest() {}
}
