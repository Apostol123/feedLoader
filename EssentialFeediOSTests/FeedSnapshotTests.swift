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
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
       let spanshot = sut.snapshot()
        
        assert(snapshot: spanshot, named: "EMPTY_FEED")
    }
    
    func test_FeedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_FeedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "ErrorMessage"))
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }
    
    func test_FeedFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithImageFailedLoading())
        
        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() ->  [FeedImageCellController] {
        return []
    }
    
    private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appending(component: snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New Snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
       let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL, options: .atomic)
        } catch {
            XCTFail("Failes to record snashot with error \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("spanshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
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

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellControllers = FeedImageCellController(delegate: stub)
            stub.controller = cellControllers
            return cellControllers
        }
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    let viewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {
        
    }
}
